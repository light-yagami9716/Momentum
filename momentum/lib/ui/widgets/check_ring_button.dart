import 'package:flutter/material.dart';

import '../../core/constants/app_motion.dart';

class CheckRingButton extends StatelessWidget {
  const CheckRingButton({
    super.key,
    required this.completed,
    required this.color,
    required this.onTap,
    this.size = 44,
  });

  final bool completed;
  final Color color;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.base,
        curve: AppMotion.spring,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: completed ? color : Colors.transparent,
          border: Border.all(
            color: completed ? color : color.withValues(alpha: 0.35),
            width: 2,
          ),
        ),
        child: AnimatedScale(
          scale: completed ? 1 : 0.92,
          duration: AppMotion.base,
          curve: AppMotion.spring,
          child: Icon(
            Icons.check_rounded,
            size: size * 0.55,
            color: completed ? Colors.white : color.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
