import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_date_utils.dart';

class WeekBarData {
  const WeekBarData({required this.day, required this.intensity});

  final DateTime day;
  final double intensity;
}

class WeekBarChart extends StatelessWidget {
  const WeekBarChart({super.key, required this.data, required this.today});

  final List<WeekBarData> data;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final chartHeight = 132.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: chartHeight,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: AppMotion.slow,
            curve: AppMotion.emphasized,
            builder: (context, t, _) {
              return CustomPaint(
                size: Size(double.infinity, chartHeight),
                painter: _WeekBarsPainter(
                  data: data,
                  progress: t,
                  accent: palette.accent,
                  track: palette.surfaceAlt,
                  future: palette.border,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final entry in data)
              Expanded(
                child: Center(
                  child: Text(
                    AppDateUtils.weekdayLabel(entry.day.weekday, short: true),
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: AppDateUtils.isSameDay(entry.day, today)
                          ? palette.accent
                          : palette.textTertiary,
                      fontWeight: AppDateUtils.isSameDay(entry.day, today)
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _WeekBarsPainter extends CustomPainter {
  const _WeekBarsPainter({
    required this.data,
    required this.progress,
    required this.accent,
    required this.track,
    required this.future,
  });

  final List<WeekBarData> data;
  final double progress;
  final Color accent;
  final Color track;
  final Color future;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final slotWidth = size.width / data.length;
    final barWidth = slotWidth * 0.42;
    final maxBarHeight = size.height - 4;

    for (var i = 0; i < data.length; i++) {
      final entry = data[i];
      final center = Offset(slotWidth * i + slotWidth / 2, size.height);
      final isFuture = entry.day.isAfter(DateTime.now());

      final fullHeight = 10 + (maxBarHeight - 10) * entry.intensity;
      final barHeight = (fullHeight * math.sqrt(progress)).clamp(
        10.0,
        maxBarHeight,
      );

      final rect = RRect.fromRectAndCorners(
        Rect.fromCenter(
          center: Offset(center.dx, size.height - barHeight / 2),
          width: barWidth,
          height: barHeight,
        ),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
        bottomLeft: const Radius.circular(6),
        bottomRight: const Radius.circular(6),
      );

      final paint = Paint()
        ..color = isFuture
            ? future
            : entry.intensity <= 0
            ? track
            : Color.lerp(track, accent, entry.intensity)!;

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_WeekBarsPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.progress != progress;
  }
}
