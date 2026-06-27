import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:aetherius/home/bullet.dart';
import 'package:aetherius/home/enemy_bullet.dart';
import 'package:aetherius/home/power_up.dart';
import 'package:aetherius/home/space_shooter_game.dart';
import 'package:flutter/material.dart';

enum EnemyType { basic, fast, tank }

class Enemy extends SpriteComponent
    with CollisionCallbacks, HasGameReference<SpaceShooterGame> {
  final EnemyType type;
  late int _hp;
  bool _flashing = false;
  double _flashTimer = 0;

  // Tank shoot timer
  double _shootTimer = 0;
  late double _shootPeriod; // randomised per tank instance

  Enemy({this.type = EnemyType.basic})
    : super(size: _sizeFor(type), anchor: Anchor.center);

  static Vector2 _sizeFor(EnemyType t) {
    switch (t) {
      case EnemyType.basic:
        return Vector2(40, 40);
      case EnemyType.fast:
        return Vector2(32, 32);
      case EnemyType.tank:
        return Vector2(54, 54);
    }
  }

  double get _speed {
    switch (type) {
      case EnemyType.basic:
        return 200;
      case EnemyType.fast:
        return 350;
      case EnemyType.tank:
        return 100;
    }
  }

  Color get _color {
    switch (type) {
      case EnemyType.basic:
        return Colors.red;
      case EnemyType.fast:
        return const Color(0xFFAA44FF); // Purple
      case EnemyType.tank:
        return const Color(0xFFFF8800); // Orange
    }
  }

  int get _maxHp {
    switch (type) {
      case EnemyType.basic:
        return 1;
      case EnemyType.fast:
        return 1;
      case EnemyType.tank:
        return 3;
    }
  }

  int get scoreValue {
    switch (type) {
      case EnemyType.basic:
        return 10;
      case EnemyType.fast:
        return 20;
      case EnemyType.tank:
        return 50;
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _hp = _maxHp;
    sprite = await game.loadSprite('enemy.png');
    _applyColor(_color);
    angle = math.pi;
    add(RectangleHitbox());

    // Each tank fires at a random interval between 1.5 and 3.5 seconds
    if (type == EnemyType.tank) {
      _shootPeriod = 1.5 + math.Random().nextDouble() * 2.0;
    }
  }

  void _applyColor(Color c) {
    paint = Paint()..colorFilter = ColorFilter.mode(c, BlendMode.srcIn);
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += _speed * dt;

    // Flash effect for tank when hit
    if (_flashing) {
      _flashTimer -= dt;
      if (_flashTimer <= 0) {
        _flashing = false;
        _applyColor(_color);
      }
    }

    // Tank fires enemy bullets at the player
    if (type == EnemyType.tank && !game.isIntro) {
      _shootTimer += dt;
      if (_shootTimer >= _shootPeriod) {
        _shootTimer = 0;
        // Randomise next shoot interval slightly
        _shootPeriod = 1.5 + math.Random().nextDouble() * 2.0;
        _fireAtPlayer();
      }
    }

    if (position.y > game.size.y) {
      removeFromParent();
      if (game.isIntro) {
        game.decrementIntroEnemies();
      } else {
        game.loseLife();
      }
    }
  }

  void _fireAtPlayer() {
    final bullet = EnemyBullet()
      ..position = Vector2(position.x, position.y + size.y / 2);
    game.add(bullet);
  }

  void _tryDropPowerUp() {
    // Random drop chance between 2% and 12% — different every kill
    final rand = math.Random();
    final dropChance = 0.02 + rand.nextDouble() * 0.10;
    if (rand.nextDouble() < dropChance) {
      final picked = PowerUp.randomType();
      game.add(PowerUp(type: picked, spawnPosition: position.clone()));
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Bullet) {
      other.removeFromParent();
      _hp--;

      if (_hp <= 0) {
        if (!game.isIntro) {
          game.increaseScore(scoreValue);
          game.onEnemyKilled();
          _tryDropPowerUp();
        }
        removeFromParent();
        if (game.isIntro) {
          game.decrementIntroEnemies();
        }
      } else {
        // Flash white on hit (tank only)
        _flashing = true;
        _flashTimer = 0.12;
        _applyColor(Colors.white);
      }
    } else if (other == game.player) {
      if (game.isIntro) {
        removeFromParent();
        game.decrementIntroEnemies();
      } else if (!game.isShielded) {
        removeFromParent();
        game.loseLife();
      }
    }
  }
}
