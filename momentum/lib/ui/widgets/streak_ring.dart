import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/app_motion.dart';

class StreakRing extends StatelessWidget {
  const StreakRing({
    super.key,
    required this.progress,
    required this.color,
    this.size = 64,
    this.strokeWidth = 6,
    this.trackOpacity = 0.12,
    this.child,
  });

  final double progress;
  final Color color;
  final double size;
  final double strokeWidth;
  final double trackOpacity;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0, 1)),
      duration: AppMotion.slow,
      curve: AppMotion.emphasized,
      builder: (context, value, child) {
        return CustomPaint(
          painter: _RingPainter(
            progress: value,
            color: color,
            trackColor: color.withValues(alpha: trackOpacity),
            strokeWidth: strokeWidth,
          ),
          child: child,
        );
      },
      child: SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    if (progress > 0) {
      final arc = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
