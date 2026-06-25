import 'package:flame/game.dart';
import 'package:aetherius/home/game_over_overlay.dart';
import 'package:aetherius/home/main_menu_overlay.dart';
import 'package:aetherius/home/space_shooter_game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget<SpaceShooterGame>(
      game: SpaceShooterGame(),
      initialActiveOverlays: const ['MainMenu'],
      overlayBuilderMap: {
        'MainMenu': (context, game) => MainMenuOverlay(game: game),
        'GameOver': (context, game) => GameOverOverlay(game: game),
      },
    ),
  );
}
