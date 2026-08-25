import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/app.dart';
import 'package:momentum/data/services/persistence_service.dart';
import 'package:momentum/state/habits_provider.dart';
import 'package:momentum/state/settings_provider.dart';
import 'package:momentum/state/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget buildApp(SharedPreferences prefs) {
  final persistence = PersistenceService(prefs);
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider(persistence)),
      ChangeNotifierProvider(create: (_) => SettingsProvider(persistence)),
      ChangeNotifierProvider(create: (_) => HabitsProvider(persistence)),
    ],
    child: const MomentumApp(),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows onboarding on first launch', (tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(buildApp(prefs));

    expect(find.text('Welcome to Momentum'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('enters the app after onboarding and shows the empty state', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(buildApp(prefs));

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Statistics'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Start your first streak'), findsOneWidget);
  });

  testWidgets('creates a habit through the form and checks it in', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(buildApp(prefs));
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create a habit'));
    await tester.pumpAndSettle();

    expect(find.text('New habit'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Drink water');
    await tester.scrollUntilVisible(
      find.text('Create habit'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Create habit'));
    await tester.pumpAndSettle();

    expect(find.text('Drink water'), findsOneWidget);
    expect(find.text('0 of 1 done'), findsOneWidget);

    await tester.tap(find.text('Drink water'));
    await tester.pumpAndSettle();

    expect(find.text('All habits complete'), findsOneWidget);
    expect(find.text('1-day streak'), findsOneWidget);
  });
}
