import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lord_of_idea/core/di/local_storage_provider.dart';

const String _keyThemeMode = 'lord_of_idea.theme_mode';
const String _keyLocale = 'lord_of_idea.locale_language_code';

class AppSettingsState {
  const AppSettingsState({this.themeMode = ThemeMode.system, this.locale});

  final ThemeMode themeMode;
  final Locale? locale;
}

class AppSettingsNotifier extends Notifier<AppSettingsState> {
  @override
  AppSettingsState build() {
    final storage = ref.read(localStorageProvider);
    final themeModeStr = storage.getString(_keyThemeMode);
    final localeCode = storage.getString(_keyLocale);

    ThemeMode themeMode = ThemeMode.system;
    if (themeModeStr == 'light') themeMode = ThemeMode.light;
    if (themeModeStr == 'dark') themeMode = ThemeMode.dark;

    Locale? locale;
    if (localeCode != null && localeCode.isNotEmpty) {
      locale = Locale(localeCode);
    }

    return AppSettingsState(themeMode: themeMode, locale: locale);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final storage = ref.read(localStorageProvider);
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await storage.setString(_keyThemeMode, value);
    state = AppSettingsState(themeMode: mode, locale: state.locale);
  }

  Future<void> setLocale(Locale? locale) async {
    final storage = ref.read(localStorageProvider);
    final value = locale?.languageCode ?? '';
    await storage.setString(_keyLocale, value);
    state = AppSettingsState(themeMode: state.themeMode, locale: locale);
  }
}
