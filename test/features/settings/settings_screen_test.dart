import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/app.dart';
import 'package:lord_of_idea/core/di/local_storage_provider.dart';
import 'package:lord_of_idea/core/di/local_storage_service.dart';
import 'package:lord_of_idea/core/router/app_router.dart';
import 'package:lord_of_idea/features/settings/presentation/settings_screen.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('P0-9 SettingsScreen 与持久化', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('P0-9-W1: SettingsScreen 含有「主题」「语言」或等价文案', (
      WidgetTester tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localStorageProvider.overrideWithValue(storage)],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(),
          ),
        ),
      );

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
    });

    testWidgets('P0-9-W2: 点击「深色」后，上层 Theme 变为 dark', (
      WidgetTester tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localStorageProvider.overrideWithValue(storage)],
          child: Consumer(
            builder: (_, WidgetRef ref, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(appRouterProvider).go('/settings');
              });
              return const MyApp();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final darkOption = find.text('Dark').evaluate().isNotEmpty
          ? find.text('Dark')
          : find.text('深色');
      expect(darkOption, findsOneWidget);
      await tester.tap(darkOption);
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(SettingsScreen));
      expect(Theme.of(context).brightness, Brightness.dark);
    });

    testWidgets('P0-9-W3: 点击语言「中文」后，某处文案为中文', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localStorageProvider.overrideWithValue(storage)],
          child: Consumer(
            builder: (_, WidgetRef ref, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(appRouterProvider).go('/settings');
              });
              return const MyApp();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final zhOption = find.text('中文').evaluate().isNotEmpty
          ? find.text('中文')
          : find.text('Chinese');
      expect(zhOption, findsOneWidget);
      await tester.tap(zhOption);
      await tester.pumpAndSettle();

      expect(find.text('设置'), findsOneWidget);
    });
  });
}
