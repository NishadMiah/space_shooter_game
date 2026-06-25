import 'dart:math';
import 'package:aetherius/home/space_shooter_game.dart';
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

                  // Line 2: Subtitle
                  _buildStaggeredLine(
                    animation: _line2Animation,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 6),
                        Text(
                          'Defend the galaxy!',
                          style: TextStyle(
                            color: Color(0xFF5C3A21),
                            fontSize: 15,
                            fontFamily: 'serif',
                            fontStyle: FontStyle.italic,
                          ),
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
                            widget.game.startGame();
                          },
                          child: const Text('PLAY'),
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

    // Top Edge (Left to Right)
    path.moveTo(0, 0);
    const steps = 30;
    for (int i = 0; i <= steps; i++) {
      double x = (size.width / steps) * i;
      double y = (i == 0 || i == steps)
          ? 0
          : (sin(i * 1.5) * 2.0 + cos(i * 2.7) * 1.5);
      path.lineTo(x, y);
    }

    // Right Edge (Top to Bottom)
    for (int i = 0; i <= steps; i++) {
      double y = (size.height / steps) * i;
      double x =
          size.width -
          ((i == 0 || i == steps)
              ? 0
              : (sin(i * 1.3) * 2.0 + cos(i * 2.9) * 1.5));
      path.lineTo(x, y);
    }

    // Bottom Edge (Right to Left)
    for (int i = steps; i >= 0; i--) {
      double x = (size.width / steps) * i;
      double y =
          size.height -
          ((i == 0 || i == steps)
              ? 0
              : (sin(i * 1.6) * 2.0 + cos(i * 2.5) * 1.5));
      path.lineTo(x, y);
    }

    // Left Edge (Bottom to Top)
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

    // 1. Draw rugged inner border slightly inside the edge
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

    // 2. Draw age stains (soft large circles)
    final stainPaint = Paint()
      ..color = const Color(0xFF8B6B4F).withAlpha(15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.2),
      35,
      stainPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.75),
      45,
      stainPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.45, size.height * 0.5),
      25,
      stainPaint,
    );

    // 3. Draw crack lines (weathered, dried paper splits)
    final crackPaint = Paint()
      ..color = const Color(0xFF3E2723).withAlpha(90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Crack 1 (Top Left)
    final crack1 = Path()
      ..moveTo(size.width * 0.08, size.height * 0.12)
      ..lineTo(size.width * 0.13, size.height * 0.16)
      ..lineTo(size.width * 0.11, size.height * 0.22)
      ..lineTo(size.width * 0.16, size.height * 0.25)
      ..lineTo(size.width * 0.14, size.height * 0.31);
    canvas.drawPath(crack1, crackPaint);

    // Crack 2 (Bottom Right)
    final crack2 = Path()
      ..moveTo(size.width * 0.92, size.height * 0.78)
      ..lineTo(size.width * 0.86, size.height * 0.75)
      ..lineTo(size.width * 0.88, size.height * 0.69)
      ..lineTo(size.width * 0.82, size.height * 0.66)
      ..lineTo(size.width * 0.84, size.height * 0.58);
    canvas.drawPath(crack2, crackPaint);

    // Crack 3 (Top Right edge)
    final crack3 = Path()
      ..moveTo(size.width * 0.94, size.height * 0.24)
      ..lineTo(size.width * 0.89, size.height * 0.26)
      ..lineTo(size.width * 0.91, size.height * 0.31)
      ..lineTo(size.width * 0.85, size.height * 0.34);
    canvas.drawPath(crack3, crackPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
