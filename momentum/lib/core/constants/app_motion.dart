import 'package:flutter/animation.dart';

class AppMotion {
  const AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration page = Duration(milliseconds: 320);

  static const Curve entry = Cubic(0.2, 0, 0, 1);
  static const Curve exit = Cubic(0.4, 0, 1, 1);
  static const Curve emphasized = Cubic(0.05, 0.7, 0.1, 1);
  static const Curve spring = Cubic(0.18, 0.89, 0.32, 1.14);
}
