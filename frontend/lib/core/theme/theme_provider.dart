import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadTheme();
  }

  void _loadTheme() {
    try {
      final box = Hive.box('auth');
      final savedTheme = box.get('theme_mode', defaultValue: 'dark') as String;
      if (savedTheme == 'light') {
        state = ThemeMode.light;
      } else if (savedTheme == 'system') {
        state = ThemeMode.system;
      } else {
        state = ThemeMode.dark;
      }
    } catch (_) {
      state = ThemeMode.dark;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    try {
      final box = Hive.box('auth');
      String value = 'dark';
      if (mode == ThemeMode.light) {
        value = 'light';
      } else if (mode == ThemeMode.system) {
        value = 'system';
      }
      await box.put('theme_mode', value);
    } catch (_) {}
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
