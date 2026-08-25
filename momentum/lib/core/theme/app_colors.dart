import 'package:flutter/material.dart';

class MomentumPalette {
  const MomentumPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.scrim,
    required this.shadow,
  });

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color accent;
  final Color onAccent;
  final Color accentSoft;
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;
  final Color scrim;
  final Color shadow;

  static const light = MomentumPalette(
    brightness: Brightness.light,
    background: Color(0xFFFAFAF8),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF2F2EF),
    textPrimary: Color(0xFF17171C),
    textSecondary: Color(0xFF6C6C75),
    textTertiary: Color(0xFF9C9CA4),
    border: Color(0xFFE9E9E4),
    accent: Color(0xFF5B5BD6),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0xFFECECF8),
    success: Color(0xFF1E9E6A),
    successSoft: Color(0xFFE4F5EE),
    warning: Color(0xFFD98A24),
    warningSoft: Color(0xFFFBF0DE),
    danger: Color(0xFFE5484D),
    dangerSoft: Color(0xFFFCE9EA),
    scrim: Color(0x66101014),
    shadow: Color(0x14101014),
  );

  static const dark = MomentumPalette(
    brightness: Brightness.dark,
    background: Color(0xFF0E0F13),
    surface: Color(0xFF16171D),
    surfaceAlt: Color(0xFF1D1F27),
    textPrimary: Color(0xFFF4F4F6),
    textSecondary: Color(0xFFA0A0AA),
    textTertiary: Color(0xFF67676F),
    border: Color(0xFF262832),
    accent: Color(0xFF8B8BF2),
    onAccent: Color(0xFF12121A),
    accentSoft: Color(0xFF232338),
    success: Color(0xFF43D68D),
    successSoft: Color(0xFF12301F),
    warning: Color(0xFFF0B054),
    warningSoft: Color(0xFF33270F),
    danger: Color(0xFFFF7075),
    dangerSoft: Color(0xFF3A1A1D),
    scrim: Color(0x990E0F13),
    shadow: Color(0x00000000),
  );
}

class HabitColors {
  static const List<Color> presets = [
    Color(0xFF6E5BF2),
    Color(0xFF3D9BF5),
    Color(0xFF2EBD8B),
    Color(0xFFEFAF2E),
    Color(0xFFEF6445),
    Color(0xFFE96AA8),
    Color(0xFF23B0A5),
    Color(0xFF748296),
  ];

  static Color at(int index) => presets[index % presets.length];

  static int get count => presets.length;
}

extension PaletteContext on BuildContext {
  MomentumPalette get palette {
    return switch (Theme.of(this).brightness) {
      Brightness.light => MomentumPalette.light,
      Brightness.dark => MomentumPalette.dark,
    };
  }
}
