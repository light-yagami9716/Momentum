import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'state/settings_provider.dart';
import 'state/theme_provider.dart';
import 'ui/navigation/app_routes.dart';

class MomentumApp extends StatelessWidget {
  const MomentumApp({super.key, this.initialTab = 0, this.initialRoute});

  final int initialTab;
  final String? initialRoute;

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().mode;
    final onboarded = context.watch<SettingsProvider>().onboarded;
    final startRoute =
        initialRoute ?? (onboarded ? AppRoutes.root : AppRoutes.onboarding);

    return MaterialApp(
      title: 'Momentum',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      initialRoute: startRoute,
      onGenerateInitialRoutes: (route) {
        return [
          AppRoutes.onGenerateRoute(
            RouteSettings(name: route, arguments: initialTab),
          ),
        ];
      },
    );
  }
}
