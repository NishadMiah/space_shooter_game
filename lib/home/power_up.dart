import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:aetherius/home/space_shooter_game.dart';
import 'package:flutter/material.dart';

enum PowerUpType { heart, shield, speed }

class PowerUp extends PositionComponent
    with CollisionCallbacks, HasGameReference<SpaceShooterGame> {
  final PowerUpType type;
  final double _speed = 150;
  late TextComponent _icon;
  double _animTimer = 0;

  PowerUp({required this.type, required Vector2 spawnPosition})
      : super(size: Vector2(32, 32), anchor: Anchor.center) {
    position = spawnPosition;
  }

  String get _emoji {
    switch (type) {
      case PowerUpType.heart:
        return '❤️';
      case PowerUpType.shield:
        return '🛡️';
      case PowerUpType.speed:
        return '⚡';
    }
  }

  Color get _glowColor {
    switch (type) {
      case PowerUpType.heart:
        return const Color(0xFFFF4466);
      case PowerUpType.shield:
        return const Color(0xFF44AAFF);
      case PowerUpType.speed:
        return const Color(0xFFFFDD00);
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Glowing background circle
    add(
      CircleComponent(
        radius: 16,
        paint: Paint()
          ..color = _glowColor.withAlpha(60)
          ..style = PaintingStyle.fill,
      ),
    );

    // Emoji icon
    _icon = TextComponent(
      text: _emoji,
      position: Vector2(16, 16),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 18),
      ),
    );
    add(_icon);

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += _speed * dt;

    // Gentle bobbing
    _animTimer += dt;
    _icon.position.y = 16 + math.sin(_animTimer * 4) * 2;

    if (position.y > game.size.y + 40) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other == game.player) {
      game.collectPowerUp(type);
      removeFromParent();
    }
  }
}
