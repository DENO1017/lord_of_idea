import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lord_of_idea/app.dart';
import 'package:lord_of_idea/core/di/local_storage_provider.dart';
import 'package:lord_of_idea/core/di/local_storage_service.dart';
import 'package:lord_of_idea/core/router/app_router.dart';
import 'package:lord_of_idea/features/settings/presentation/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('P0-9-I1 集成', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('从启动到打开设置页、切换主题，无崩溃且界面正确', (WidgetTester tester) async {
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

      expect(find.byType(SettingsScreen), findsOneWidget);

      final darkOption = find.text('Dark').evaluate().isNotEmpty
          ? find.text('Dark')
          : find.text('深色');
      await tester.tap(darkOption);
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(SettingsScreen));
      expect(Theme.of(context).brightness, Brightness.dark);
    });
  });
}
