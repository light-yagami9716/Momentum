import 'package:flutter/material.dart';

import '../data/services/persistence_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._persistence) {
    _mode = _loadMode();
  }

  final PersistenceService _persistence;

  late ThemeMode _mode;

  ThemeMode get mode => _mode;

  ThemeMode _loadMode() {
    return switch (_persistence.readThemeMode()) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    await _persistence.writeThemeMode(mode.name);
  }
}
