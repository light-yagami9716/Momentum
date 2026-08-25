import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_date_utils.dart';

class MonthHeatmap extends StatelessWidget {
  const MonthHeatmap({
    super.key,
    required this.month,
    required this.intensityFor,
    required this.weekStartsMonday,
    this.onPreviousMonth,
    this.onNextMonth,
  });

  final DateTime month;
  final double Function(DateTime day) intensityFor;
  final bool weekStartsMonday;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final today = AppDateUtils.today();
    final firstDay = AppDateUtils.firstDayOfMonth(month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = weekStartsMonday
        ? firstDay.weekday - 1
        : firstDay.weekday % 7;

    final monthLabel = _monthLabel(month);
    final canGoNext = !(month.year >= today.year && month.month >= today.month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                monthLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            _MonthButton(
              icon: Icons.chevron_left_rounded,
              onTap: onPreviousMonth,
            ),
            const SizedBox(width: 4),
            _MonthButton(
              icon: Icons.chevron_right_rounded,
              onTap: canGoNext ? onNextMonth : null,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    AppDateUtils.weekdayLabel(
                      weekStartsMonday ? (i % 7) + 1 : ((i + 6) % 7) + 1,
                      short: true,
                    ),
                    style: Theme.of(context).textTheme.labelSmall!
                        .copyWith(color: palette.textTertiary),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: leading + daysInMonth,
          itemBuilder: (context, index) {
            if (index < leading) return const SizedBox.shrink();

            final day = DateTime(month.year, month.month, index - leading + 1);
            final isFuture = day.isAfter(today);
            final isToday = AppDateUtils.isSameDay(day, today);
            final intensity = isFuture ? 0.0 : intensityFor(day);

            return CustomPaint(
              painter: _HeatCellPainter(
                color: Color.lerp(
                  palette.surfaceAlt,
                  palette.accent,
                  intensity,
                )!,
                outline: isToday ? palette.accent : null,
                dimmed: isFuture,
              ),
            );
          },
        ),
      ],
    );
  }

  String _monthLabel(DateTime month) {
    const names = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${names[month.month]} ${month.year}';
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.surfaceAlt,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 20,
            color: onTap == null ? palette.textTertiary : palette.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _HeatCellPainter extends CustomPainter {
  const _HeatCellPainter({
    required this.color,
    required this.dimmed,
    this.outline,
  });

  final Color color;
  final Color? outline;
  final bool dimmed;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(size.width * 0.24),
    );

    final fill = Paint()..color = dimmed ? Colors.transparent : color;
    canvas.drawRRect(rrect, fill);

    if (outline != null) {
      final stroke = Paint()
        ..color = outline!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(rrect.deflate(1), stroke);
    }
  }

  @override
  bool shouldRepaint(_HeatCellPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.outline != outline ||
        oldDelegate.dimmed != dimmed;
  }
}
