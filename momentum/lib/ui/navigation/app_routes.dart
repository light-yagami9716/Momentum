import 'package:flutter/material.dart';

import '../../ui/habit_form/add_edit_habit_screen.dart';
import '../../ui/onboarding/onboarding_screen.dart';
import '../../ui/root_shell.dart';
import '../../ui/settings/settings_screen.dart';
import '../../ui/statistics/statistics_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const onboarding = '/onboarding';
  static const root = '/';
  static const addHabit = '/habit/new';
  static const editHabit = '/habit/edit';
  static const statistics = '/statistics';
  static const settings = '/settings';

  static Route<void> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case onboarding:
        return _fade(const OnboardingScreen(), routeSettings);
      case root:
        final tab = routeSettings.arguments as int? ?? 0;
        return _fade(RootShell(initialTab: tab), routeSettings);
      case addHabit:
        return _material(const AddEditHabitScreen(), routeSettings);
      case editHabit:
        final habitId = routeSettings.arguments as String?;
        return _material(AddEditHabitScreen(habitId: habitId), routeSettings);
      case statistics:
        return _fade(const StatisticsScreen(), routeSettings);
      case settings:
        return _fade(const SettingsScreen(), routeSettings);
      default:
        return _fade(const RootShell(), routeSettings);
    }
  }

  static Route<void> _material(Widget page, RouteSettings settings) {
    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }

  static Route<void> _fade(Widget page, RouteSettings settings) {
    return PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => page,
      settings: settings,
      transitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (_, animation, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }
}
