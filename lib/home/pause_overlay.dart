import 'package:aetherius/home/space_shooter_game.dart';
import 'package:aetherius/home/parchment_theme.dart';
import 'package:flutter/material.dart';

/// Small Pause Button overlay shown during gameplay.
class PauseButtonOverlay extends StatelessWidget {
  final SpaceShooterGame game;
  const PauseButtonOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, right: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(80),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: IconButton(
              icon: const Icon(Icons.pause_rounded, color: Colors.white, size: 24),
              onPressed: () {
                game.pauseEngine();
                game.overlays.remove('PauseButton');
                game.overlays.add('PauseMenu');
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Parchment-style Pause Menu shown when the game is paused.
class PauseMenuOverlay extends StatelessWidget {
  final SpaceShooterGame game;
  const PauseMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipPath(
        clipper: ParchmentClipper(),
        child: CustomPaint(
          painter: ParchmentPainter(),
          child: Container(
            width: 280,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.85,
                colors: [
                  Color(0xFFFDF6E2),
                  Color(0xFFF5E6CA),
                  Color(0xFFDCC298),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  height: 2,
                  width: 60,
                  color: const Color(0xFF5C3A21).withAlpha(180),
                ),
                const SizedBox(height: 12),
                const Text(
                  'PAUSED',
                  style: TextStyle(
                    color: Color(0xFF2C1607),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Current Level: ${game.currentLevel}',
                  style: const TextStyle(
                    color: Color(0xFF4A3220),
                    fontSize: 14,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // Button: Resume
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C1607),
                    foregroundColor: const Color(0xFFFDF6E2),
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                      letterSpacing: 1.5,
                    ),
                  ),
                  onPressed: () {
                    game.resumeEngine();
                    game.overlays.remove('PauseMenu');
                    game.overlays.add('PauseButton');
                  },
                  child: const Text('RESUME'),
                ),
                const SizedBox(height: 12),

                // Button: Restart Level
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A1C14),
                    foregroundColor: const Color(0xFFFDF6E2),
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: const BorderSide(color: Color(0xFF5C100B), width: 1.5),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                      letterSpacing: 1.5,
                    ),
                  ),
                  onPressed: () {
                    game.resumeEngine();
                    game.overlays.remove('PauseMenu');
                    game.overlays.add('PauseButton');
                    game.restart();
                  },
                  child: const Text('RESTART LEVEL'),
                ),
                const SizedBox(height: 12),

                // Button: Main Menu
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2C1607),
                    minimumSize: const Size(double.infinity, 40),
                    side: const BorderSide(color: Color(0xFF5C3A21), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'serif',
                      letterSpacing: 1,
                    ),
                  ),
                  onPressed: () {
                    game.resumeEngine();
                    game.overlays.remove('PauseMenu');
                    game.returnToLevelSelect();
                  },
                  child: const Text('QUIT TO MENU'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
