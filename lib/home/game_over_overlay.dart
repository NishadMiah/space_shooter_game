import 'dart:math';
import 'package:aetherius/home/space_shooter_game.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    // 1. Unfolding animation
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

    // 2. Staggered printing/fade-in
    _line1Animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.62, curve: Curves.easeOut),
    );

    _line2Animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.62, 0.80, curve: Curves.easeOut),
    );

    _line3Animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.80, 1.0, curve: Curves.easeOut),
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
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
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
                  // Line 1: Header/Title
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
                            color: Color(
                              0xFF6B1D1D,
                            ), // Deep crimson/dried blood color
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

                  // Line 2: Score Display & Separator
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
                        const SizedBox(height: 20),
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

                  // Line 3: Restart Button
                  _buildStaggeredLine(
                    animation: _line3Animation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 28),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF8A1C14,
                            ), // Wax seal red
                            foregroundColor: const Color(0xFFFDF6E2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: const BorderSide(
                                color: Color(0xFF5C100B),
                                width: 2,
                              ),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'serif',
                              letterSpacing: 1.5,
                            ),
                            elevation: 5,
                            shadowColor: Colors.black,
                          ),
                          onPressed: () {
                            widget.game.reset();
                          },
                          child: const Text('RESTART'),
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

class ParchmentClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Top Edge
    path.moveTo(0, 0);
    const steps = 30;
    for (int i = 0; i <= steps; i++) {
      double x = (size.width / steps) * i;
      double y = (i == 0 || i == steps)
          ? 0
          : (sin(i * 1.5) * 2.0 + cos(i * 2.7) * 1.5);
      path.lineTo(x, y);
    }

    // Right Edge
    for (int i = 0; i <= steps; i++) {
      double y = (size.height / steps) * i;
      double x =
          size.width -
          ((i == 0 || i == steps)
              ? 0
              : (sin(i * 1.3) * 2.0 + cos(i * 2.9) * 1.5));
      path.lineTo(x, y);
    }

    // Bottom Edge
    for (int i = steps; i >= 0; i--) {
      double x = (size.width / steps) * i;
      double y =
          size.height -
          ((i == 0 || i == steps)
              ? 0
              : (sin(i * 1.6) * 2.0 + cos(i * 2.5) * 1.5));
      path.lineTo(x, y);
    }

    // Left Edge
    for (int i = steps; i >= 0; i--) {
      double y = (size.height / steps) * i;
      double x = (i == 0 || i == steps)
          ? 0
          : (sin(i * 1.4) * 2.0 + cos(i * 2.8) * 1.5);
      path.lineTo(x, y);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class ParchmentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5C3A21).withAlpha(120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final borderPath = Path();
    const steps = 30;
    const padding = 6.0;

    // Top
    borderPath.moveTo(padding, padding);
    for (int i = 0; i <= steps; i++) {
      double x = padding + ((size.width - padding * 2) / steps) * i;
      double y =
          padding +
          ((i == 0 || i == steps)
              ? 0
              : (sin(i * 1.1) * 1.5 + cos(i * 2.3) * 1.0));
      borderPath.lineTo(x, y);
    }
    // Right
    for (int i = 0; i <= steps; i++) {
      double y = padding + ((size.height - padding * 2) / steps) * i;
      double x =
          size.width -
          padding -
          ((i == 0 || i == steps)
              ? 0
              : (sin(i * 1.4) * 1.5 + cos(i * 2.1) * 1.0));
      borderPath.lineTo(x, y);
    }
    // Bottom
    for (int i = steps; i >= 0; i--) {
      double x = padding + ((size.width - padding * 2) / steps) * i;
      double y =
          size.height -
          padding -
          ((i == 0 || i == steps)
              ? 0
              : (sin(i * 1.2) * 1.5 + cos(i * 2.5) * 1.0));
      borderPath.lineTo(x, y);
    }
    // Left
    for (int i = steps; i >= 0; i--) {
      double y = padding + ((size.height - padding * 2) / steps) * i;
      double x =
          padding +
          ((i == 0 || i == steps)
              ? 0
              : (sin(i * 1.3) * 1.5 + cos(i * 2.2) * 1.0));
      borderPath.lineTo(x, y);
    }
    borderPath.close();
    canvas.drawPath(borderPath, paint);

    // Stains
    final stainPaint = Paint()
      ..color = const Color(0xFF8B6B4F).withAlpha(15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.25),
      30,
      stainPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.7),
      40,
      stainPaint,
    );

    // Cracks
    final crackPaint = Paint()
      ..color = const Color(0xFF3E2723).withAlpha(90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final crack1 = Path()
      ..moveTo(size.width * 0.1, size.height * 0.15)
      ..lineTo(size.width * 0.15, size.height * 0.18)
      ..lineTo(size.width * 0.13, size.height * 0.24)
      ..lineTo(size.width * 0.18, size.height * 0.27);
    canvas.drawPath(crack1, crackPaint);

    final crack2 = Path()
      ..moveTo(size.width * 0.9, size.height * 0.8)
      ..lineTo(size.width * 0.84, size.height * 0.77)
      ..lineTo(size.width * 0.86, size.height * 0.71)
      ..lineTo(size.width * 0.8, size.height * 0.68);
    canvas.drawPath(crack2, crackPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
