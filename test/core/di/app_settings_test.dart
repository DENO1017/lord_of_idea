import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/core/di/app_settings_provider.dart';
import 'package:lord_of_idea/core/di/local_storage_provider.dart';
import 'package:lord_of_idea/core/di/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('P0-6 AppSettingsNotifier', () {
    late SharedPreferences prefs;
    late LocalStorageService storage;

    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      prefs = await SharedPreferences.getInstance();
      storage = LocalStorageService(prefs);
    });

    test('P0-6-U1: 初始状态：无持久化时 themeMode 为 system，locale 为 null', () async {
      final container = ProviderContainer(
        overrides: [localStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      final state = container.read(appSettingsProvider);
      expect(state.themeMode, ThemeMode.system);
      expect(state.locale, isNull);
    });

    test(
      'P0-6-U2: setThemeMode(ThemeMode.dark) 后 state 为 dark，且写入存储',
      () async {
        final container = ProviderContainer(
          overrides: [localStorageProvider.overrideWithValue(storage)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(appSettingsProvider.notifier);
        await notifier.setThemeMode(ThemeMode.dark);

        final state = container.read(appSettingsProvider);
        expect(state.themeMode, ThemeMode.dark);
        expect(storage.getString('lord_of_idea.theme_mode'), 'dark');
      },
    );

    test('P0-6-U3: 从持久化恢复：存储中为 dark 时，state.themeMode 为 dark', () async {
      SharedPreferences.setMockInitialValues({
        'lord_of_idea.theme_mode': 'dark',
      });
      final prefsForRestore = await SharedPreferences.getInstance();
      final storageForRestore = LocalStorageService(prefsForRestore);

      final container = ProviderContainer(
        overrides: [localStorageProvider.overrideWithValue(storageForRestore)],
      );
      addTearDown(container.dispose);

      final state = container.read(appSettingsProvider);
      expect(state.themeMode, ThemeMode.dark);
    });

    test(
      'P0-6-U4: setLocale 写入 lord_of_idea.locale_language_code 并从 state 读回',
      () async {
        final container = ProviderContainer(
          overrides: [localStorageProvider.overrideWithValue(storage)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(appSettingsProvider.notifier);
        await notifier.setLocale(const Locale('zh'));

        final state = container.read(appSettingsProvider);
        expect(state.locale?.languageCode, 'zh');
        expect(storage.getString('lord_of_idea.locale_language_code'), 'zh');
      },
    );
  });
}
