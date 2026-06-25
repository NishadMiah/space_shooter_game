import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:aetherius/home/space_shooter_game.dart';

class Bullet extends SpriteComponent
    with CollisionCallbacks, HasGameReference<SpaceShooterGame> {
  Bullet() : super(size: Vector2(10, 20));

  final double speed = 500;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await game.loadSprite('bullet.png');
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
