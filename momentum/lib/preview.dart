import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/utils/app_date_utils.dart';
import 'data/models/habit.dart';
import 'data/services/persistence_service.dart';
import 'state/habits_provider.dart';
import 'state/settings_provider.dart';
import 'state/theme_provider.dart';

int _lcg(int seed) => (seed * 1103515245 + 12345) % 2147483648;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await prefs.setBool('momentum.onboarded', true);

  final themeOverride = Uri.base.queryParameters['theme'];
  if (themeOverride != null &&
      (themeOverride == 'light' || themeOverride == 'dark')) {
    await prefs.setString('momentum.themeMode', themeOverride);
  }

  final today = AppDateUtils.today();

  const seeds = [
    (
      id: 'demo-water',
      name: 'Drink water',
      iconKey: 'water_drop',
      colorIndex: 0,
      frequency: HabitFrequency.daily,
      days: <int>[],
      createdOffset: 42,
      chance: 92,
      forcedStreak: 12,
    ),
    (
      id: 'demo-read',
      name: 'Read 20 pages',
      iconKey: 'book',
      colorIndex: 1,
      frequency: HabitFrequency.daily,
      days: <int>[],
      createdOffset: 38,
      chance: 76,
      forcedStreak: 4,
    ),
    (
      id: 'demo-gym',
      name: 'Gym session',
      iconKey: 'fitness',
      colorIndex: 2,
      frequency: HabitFrequency.specificDays,
      days: <int>[1, 3, 5],
      createdOffset: 42,
      chance: 82,
      forcedStreak: 5,
    ),
    (
      id: 'demo-meditate',
      name: 'Meditate',
      iconKey: 'self_improvement',
      colorIndex: 6,
      frequency: HabitFrequency.daily,
      days: <int>[],
      createdOffset: 28,
      chance: 64,
      forcedStreak: 0,
    ),
    (
      id: 'demo-sleep',
      name: 'Sleep by 11pm',
      iconKey: 'bedtime',
      colorIndex: 3,
      frequency: HabitFrequency.daily,
      days: <int>[],
      createdOffset: 35,
      chance: 48,
      forcedStreak: 0,
    ),
  ];

  final habitsJson = <Map<String, dynamic>>[];
  final completions = <String, List<String>>{};

  for (final seed in seeds) {
    final created = AppDateUtils.addDays(today, -seed.createdOffset);
    habitsJson.add({
      'id': seed.id,
      'name': seed.name,
      'iconKey': seed.iconKey,
      'colorIndex': seed.colorIndex,
      'frequency': seed.frequency.name,
      'days': seed.days,
      'createdDate':
          '${created.year.toString().padLeft(4, '0')}-'
          '${created.month.toString().padLeft(2, '0')}-'
          '${created.day.toString().padLeft(2, '0')}',
      'reminderMinutes': null,
      'archived': false,
    });

    final keys = <String>{};
    final habit = Habit.fromJson(habitsJson.last);

    for (
      var day = created;
      !day.isAfter(today);
      day = AppDateUtils.addDays(day, 1)
    ) {
      if (!habit.isScheduledOn(day)) continue;
      final roll =
          _lcg(day.day * 31 + day.month * 7 + day.year + seed.id.length) % 100;
      if (roll < seed.chance) {
        keys.add(AppDateUtils.dateKey(day));
      }
    }

    for (var i = 0; i < seed.forcedStreak; i++) {
      final day = AppDateUtils.addDays(today, -i);
      if (habit.isScheduledOn(day)) {
        keys.add(AppDateUtils.dateKey(day));
      }
    }

    completions[seed.id] = keys.toList()..sort();
  }

  await prefs.setString('momentum.habits', jsonEncode(habitsJson));
  await prefs.setString('momentum.completions', jsonEncode(completions));

  final tab = switch (Uri.base.queryParameters['tab']) {
    'stats' => 1,
    'settings' => 2,
    _ => 0,
  };
  final startAtForm = Uri.base.queryParameters['form'] == '1';
  final initialRoute = startAtForm ? '/habit/new' : null;

  final persistence = PersistenceService(prefs);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(persistence)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(persistence)),
        ChangeNotifierProvider(create: (_) => HabitsProvider(persistence)),
      ],
      child: MomentumApp(initialTab: tab, initialRoute: initialRoute),
    ),
  );
}
