import 'package:aetherius/home/space_shooter_game.dart';
import 'package:aetherius/home/parchment_theme.dart';
import 'package:aetherius/home/sound_service.dart';
import 'package:flutter/material.dart';

class MainMenuOverlay extends StatefulWidget {
  final SpaceShooterGame game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _unfoldWidthAnimation;
  late Animation<double> _unfoldHeightAnimation;
  late Animation<double> _line1Animation;
  late Animation<double> _line2Animation;
  late Animation<double> _line3Animation;
  late Animation<double> _line4Animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2600),
      vsync: this,
    );

    // 1. Unfolding animation (from 0s to 1.1s)
    _unfoldWidthAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _unfoldHeightAnimation = Tween<double>(begin: 0.01, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.48, curve: Curves.easeOutBack),
      ),
    );

    // 2. Staggered printing/fade-in (from 1.1s to 2.6s)
    _line1Animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.48, 0.61, curve: Curves.easeOut),
    );

    _line2Animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.61, 0.74, curve: Curves.easeOut),
    );

    _line3Animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.74, 0.87, curve: Curves.easeOut),
    );

    _line4Animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.87, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStaggeredLine({
    required Animation<double> animation,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1.0 - animation.value)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(
              _unfoldWidthAnimation.value,
              _unfoldHeightAnimation.value,
              1.0,
            ),
            child: child,
          );
        },
        child: ClipPath(
          clipper: ParchmentClipper(),
          child: CustomPaint(
            painter: ParchmentPainter(),
            child: Container(
              width: 320,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    Color(0xFFFDF6E2), // Bright center
                    Color(0xFFF5E6CA), // Medium paper
                    Color(0xFFDCC298), // Aged edges
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Line 1: Top line & Title
                  _buildStaggeredLine(
                    animation: _line1Animation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 2,
                          width: 80,
                          color: const Color(0xFF5C3A21).withAlpha(180),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'AETHERIUS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF2C1607),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif',
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: Colors.white,
                                offset: Offset(1, 1),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Line 2: Subtitle + High Score
                  _buildStaggeredLine(
                    animation: _line2Animation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 6),
                        const Text(
                          'Defend the galaxy!',
                          style: TextStyle(
                            color: Color(0xFF5C3A21),
                            fontSize: 15,
                            fontFamily: 'serif',
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '🏆  Best: ',
                              style: TextStyle(
                                color: Color(0xFF7A5500),
                                fontSize: 14,
                                fontFamily: 'serif',
                              ),
                            ),
                            Text(
                              '${widget.game.highScore}',
                              style: const TextStyle(
                                color: Color(0xFF7A5500),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'serif',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Line 3: Separator & Controls Box
                  _buildStaggeredLine(
                    animation: _line3Animation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 1,
                              width: 40,
                              color: const Color(0xFF5C3A21).withAlpha(100),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.star,
                                color: Color(0xFF5C3A21),
                                size: 12,
                              ),
                            ),
                            Container(
                              height: 1,
                              width: 40,
                              color: const Color(0xFF5C3A21).withAlpha(100),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5C3A21).withAlpha(15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF5C3A21).withAlpha(60),
                              width: 1.5,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'CONTROLS',
                                style: TextStyle(
                                  color: Color(0xFF2C1607),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'serif',
                                  letterSpacing: 1.5,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '• Drag to move horizontally\n• Tap to shoot extra bullets',
                                style: TextStyle(
                                  color: Color(0xFF4A3220),
                                  fontSize: 12,
                                  fontFamily: 'serif',
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Line 4: Play Button
                  _buildStaggeredLine(
                    animation: _line4Animation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 28),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A1C14),
                            foregroundColor: const Color(0xFFFDF6E2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: const BorderSide(
                                color: Color(0xFF5C100B),
                                width: 2,
                              ),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'serif',
                              letterSpacing: 2,
                            ),
                            elevation: 6,
                            shadowColor: Colors.black,
                          ),
                          onPressed: () {
                            widget.game.overlays.remove('MainMenu');
                            widget.game.overlays.add('LevelSelect');
                          },
                          child: const Text('SELECT LEVEL'),
                        ),
                        const SizedBox(height: 14),
                        IconButton(
                          icon: Icon(
                            SoundService.enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                            color: const Color(0xFF5C3A21),
                            size: 28,
                          ),
                          onPressed: () async {
                            await SoundService.toggleSound();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
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
