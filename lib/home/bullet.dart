import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Bullet extends RectangleComponent with CollisionCallbacks {
  Bullet()
    : super(size: Vector2(10, 20), paint: Paint()..color = Colors.yellow);

  final double speed = 500;
  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y -= speed * dt;

    if (position.y < 0) {
      removeFromParent();
    }
  }
}
