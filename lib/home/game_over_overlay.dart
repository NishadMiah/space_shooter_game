import 'package:aetherius/home/space_shooter_game.dart';
import 'package:aetherius/home/parchment_theme.dart';
import 'package:flutter/material.dart';

class GameOverOverlay extends StatefulWidget {
  final SpaceShooterGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
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
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _unfoldWidthAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _unfoldHeightAnimation = Tween<double>(begin: 0.01, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.18, 0.45, curve: Curves.easeOutBack),
      ),
    );

    _line1Animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.60, curve: Curves.easeOut),
    );
    _line2Animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.60, 0.75, curve: Curves.easeOut),
    );
    _line3Animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 0.88, curve: Curves.easeOut),
    );
    _line4Animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.88, 1.0, curve: Curves.easeOut),
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
    final isNewHighScore =
        widget.game.score > 0 && widget.game.score >= widget.game.highScore;

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
              width: 310,
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
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
                  // ── Line 1: Title ──────────────────────────────────────
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
                          'GAME OVER',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF6B1D1D),
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

                  // ── Line 2: Score & Level ──────────────────────────────
                  _buildStaggeredLine(
                    animation: _line2Animation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 1,
                              width: 35,
                              color: const Color(0xFF5C3A21).withAlpha(100),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.circle,
                                color: Color(0xFF5C3A21),
                                size: 6,
                              ),
                            ),
                            Container(
                              height: 1,
                              width: 35,
                              color: const Color(0xFF5C3A21).withAlpha(100),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Level reached badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C1607).withAlpha(12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF5C3A21).withAlpha(60),
                            ),
                          ),
                          child: Text(
                            '⚔️  Level ${widget.game.currentLevel} Reached',
                            style: const TextStyle(
                              color: Color(0xFF2C1607),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'serif',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Score: ${widget.game.score}',
                          style: const TextStyle(
                            color: Color(0xFF2C1607),
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'serif',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Line 3: High Score ─────────────────────────────────
                  _buildStaggeredLine(
                    animation: _line3Animation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        if (isNewHighScore)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDD00).withAlpha(40),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFBB8800),
                                width: 1.5,
                              ),
                            ),
                            child: const Text(
                              '🏆  NEW HIGH SCORE!',
                              style: TextStyle(
                                color: Color(0xFF7A5500),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'serif',
                                letterSpacing: 1,
                              ),
                            ),
                          )
                        else
                          Text(
                            '🏆  Best: ${widget.game.highScore}',
                            style: const TextStyle(
                              color: Color(0xFF7A5500),
                              fontSize: 14,
                              fontFamily: 'serif',
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── Line 4: Buttons ────────────────────────────────────
                  _buildStaggeredLine(
                    animation: _line4Animation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 22),
                        // RESTART — same level
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A1C14),
                            foregroundColor: const Color(0xFFFDF6E2),
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: const BorderSide(
                                color: Color(0xFF5C100B),
                                width: 2,
                              ),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'serif',
                              letterSpacing: 1.5,
                            ),
                            elevation: 5,
                            shadowColor: Colors.black,
                          ),
                          onPressed: () => widget.game.restart(),
                          child: const Text('▶  RESTART'),
                        ),
                        const SizedBox(height: 10),
                        // LEVEL SELECT
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2C1607),
                            minimumSize: const Size(double.infinity, 40),
                            side: const BorderSide(
                              color: Color(0xFF5C3A21),
                              width: 1.5,
                            ),
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
                          onPressed: () => widget.game.returnToLevelSelect(),
                          child: const Text('☰  LEVEL SELECT'),
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
