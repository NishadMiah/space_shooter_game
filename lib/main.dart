import 'package:flame/game.dart';
import 'package:flame_game/home/game_over_overlay.dart';
import 'package:flame_game/home/space_shooter_game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget<SpaceShooterGame>(
      game: SpaceShooterGame(),
      overlayBuilderMap: {
        'GameOver': (context, game) => GameOverOverlay(game: game),
      },
    ),
  );
}
