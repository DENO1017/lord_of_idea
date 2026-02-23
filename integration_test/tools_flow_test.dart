import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lord_of_idea/app.dart';
import 'package:lord_of_idea/core/di/local_storage_provider.dart';
import 'package:lord_of_idea/core/di/local_storage_service.dart';
import 'package:lord_of_idea/core/router/app_router.dart';
import 'package:lord_of_idea/features/divination/presentation/tools_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('P1-8-I1 工具页 → 骰子 → 返回', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('从启动 → 进入工具页 → 进入骰子页 → 返回工具页，无崩溃', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localStorageProvider.overrideWithValue(storage)],
          child: Consumer(
            builder: (_, WidgetRef ref, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(appRouterProvider).go('/tools');
              });
              return const MyApp();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ToolsScreen), findsOneWidget);

      await tester.tap(find.byKey(ToolsScreen.keyToolDice));
      await tester.pumpAndSettle();

      expect(find.byType(ToolsScreen), findsNothing);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(ToolsScreen), findsOneWidget);
    });
  });
}
