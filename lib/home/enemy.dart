import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_game/home/bullet.dart';
import 'package:flame_game/home/space_shooter_game.dart';
import 'package:flutter/material.dart';

class Enemy extends SpriteComponent
    with CollisionCallbacks, HasGameReference<SpaceShooterGame> {
  Enemy() : super(size: Vector2(40, 40));

  final double speed = 200;
  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await game.loadSprite('enemy.png');
    paint = Paint()
      ..colorFilter = const ColorFilter.mode(Colors.red, BlendMode.srcIn);

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += speed * dt;

    if (position.y > game.size.y) {
      removeFromParent();
      game.gameOver();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Bullet) {
      game.increaseScore();
      removeFromParent();
      other.removeFromParent();
    } else if (other == game.player) {
      game.gameOver();
    }
  }
}
