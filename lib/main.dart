import 'package:flame/game.dart';
import 'package:aetherius/home/game_over_overlay.dart';
import 'package:aetherius/home/main_menu_overlay.dart';
import 'package:aetherius/home/space_shooter_game.dart';
import 'package:aetherius/home/story_intro_overlay.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget<SpaceShooterGame>(
      game: SpaceShooterGame(),
      initialActiveOverlays: const ['StoryIntro'],
      overlayBuilderMap: {
        'StoryIntro': (context, game) => StoryIntroOverlay(game: game),
        'MainMenu': (context, game) => MainMenuOverlay(game: game),
        'GameOver': (context, game) => GameOverOverlay(game: game),
      },
    ),
  );
}
