import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_game/home/bullet.dart';
import 'package:flame_game/home/enemy.dart';
import 'package:flutter/material.dart';

class SpaceShooterGame extends FlameGame
    with PanDetector, TapCallbacks, HasCollisionDetection {
  late RectangleComponent player;
  int score = 0;
  late TextComponent scoreText;
  @override
  Future<void> onLoad() async {
    super.onLoad();

    //===== player =====
    player = RectangleComponent(
      size: Vector2(50, 50),
      paint: Paint()..color = Colors.red,
    );
    player.position = Vector2(size.x / 2, size.y - 100);
    //=== load player ====
    add(player);

    scoreText = TextComponent(
      text: 'Score: $score',
      position: Vector2(20, 40),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreText);

    add(
      SpawnComponent(
        factory: (index) => Enemy(),
        period: 1.0,
        area: Rectangle.fromLTWH(0, 0, size.x - 40, 0),
      ),
    );
  }

  void increaseScore() {
    score += 10;
    scoreText.text = 'Score: $score';
    debugPrint('Score: $score');
  }

  // ==== Drag ====
  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.position.x += info.delta.global.x;
  }

  // ==== Tap ====
  @override
  void onTapDown(TapDownEvent event) {
    // ==== Bullets ====
    final bullet = Bullet()
      ..position = Vector2(player.position.x + 20, player.position.y);

    //=== load bullet ====
    add(bullet);
  }
}
