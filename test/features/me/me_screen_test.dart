import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/app.dart';
import 'package:lord_of_idea/core/di/local_storage_provider.dart';
import 'package:lord_of_idea/core/di/local_storage_service.dart';
import 'package:lord_of_idea/core/router/app_router.dart';
import 'package:lord_of_idea/features/settings/presentation/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('P0-12 我的页（/me）及路由', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpApp(
      WidgetTester tester, {
      String initialLocation = '/me',
    }) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await storage.setString('lord_of_idea.locale_language_code', 'en');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
            appRouterProvider.overrideWithValue(
              createAppRouter(initialLocation: initialLocation),
            ),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('P0-12-W2: 路由 /me 解析为 MeScreen 或 SettingsScreen（我的页）', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, initialLocation: '/me');
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.byKey(const Key('settings_screen_title')), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
