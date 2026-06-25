import 'dart:math';
import 'package:flutter/material.dart';

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
      double x = size.width -
          ((i == 0 || i == steps) ? 0 : (sin(i * 1.3) * 2.0 + cos(i * 2.9) * 1.5));
      path.lineTo(x, y);
    }

    // Bottom Edge
    for (int i = steps; i >= 0; i--) {
      double x = (size.width / steps) * i;
      double y = size.height -
          ((i == 0 || i == steps) ? 0 : (sin(i * 1.6) * 2.0 + cos(i * 2.5) * 1.5));
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
      double y = padding +
          ((i == 0 || i == steps) ? 0 : (sin(i * 1.1) * 1.5 + cos(i * 2.3) * 1.0));
      borderPath.lineTo(x, y);
    }
    // Right
    for (int i = 0; i <= steps; i++) {
      double y = padding + ((size.height - padding * 2) / steps) * i;
      double x = size.width -
          padding -
          ((i == 0 || i == steps) ? 0 : (sin(i * 1.4) * 1.5 + cos(i * 2.1) * 1.0));
      borderPath.lineTo(x, y);
    }
    // Bottom
    for (int i = steps; i >= 0; i--) {
      double x = padding + ((size.width - padding * 2) / steps) * i;
      double y = size.height -
          padding -
          ((i == 0 || i == steps) ? 0 : (sin(i * 1.2) * 1.5 + cos(i * 2.5) * 1.0));
      borderPath.lineTo(x, y);
    }
    // Left
    for (int i = steps; i >= 0; i--) {
      double y = padding + ((size.height - padding * 2) / steps) * i;
      double x = padding +
          ((i == 0 || i == steps) ? 0 : (sin(i * 1.3) * 1.5 + cos(i * 2.2) * 1.0));
      borderPath.lineTo(x, y);
    }
    borderPath.close();
    canvas.drawPath(borderPath, paint);

    // Stains
    final stainPaint = Paint()
      ..color = const Color(0xFF8B6B4F).withAlpha(15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.25), 30, stainPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), 40, stainPaint);

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
