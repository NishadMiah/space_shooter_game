import 'package:aetherius/home/space_shooter_game.dart';
import 'package:aetherius/home/parchment_theme.dart';
import 'package:flutter/material.dart';

class StoryIntroOverlay extends StatelessWidget {
  final SpaceShooterGame game;

  const StoryIntroOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: ClipPath(
          clipper: ParchmentClipper(),
          child: CustomPaint(
            painter: ParchmentPainter(),
            child: Container(
              width: 320,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CELESTIAL THREAT',
                    style: TextStyle(
                      color: Color(0xFF6B1D1D),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Invaders have breached the gates of Aetherius! Drag to steer your vessel and Tap to destroy the approaching scout!',
                    style: TextStyle(
                      color: Color(0xFF2C1607),
                      fontSize: 13,
                      fontFamily: 'serif',
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
