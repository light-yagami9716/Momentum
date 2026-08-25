import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/services/notification_service.dart';
import 'data/services/persistence_service.dart';
import 'state/habits_provider.dart';
import 'state/settings_provider.dart';
import 'state/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final persistence = PersistenceService(prefs);

  final habits = HabitsProvider(persistence, LocalNotificationScheduler());
  await habits.bootstrap();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(persistence)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(persistence)),
        ChangeNotifierProvider.value(value: habits),
      ],
      child: const MomentumApp(),
    ),
  );
}
