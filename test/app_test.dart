import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/app.dart';
import 'package:lord_of_idea/core/di/local_storage_provider.dart';
import 'package:lord_of_idea/core/di/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('P0-1 MyApp', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('P0-1-W1: MyApp 在 ProviderScope 下能完成 build，不抛异常', (
      WidgetTester tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localStorageProvider.overrideWithValue(storage)],
          child: const MyApp(),
        ),
      );

      expect(find.byType(MyApp), findsOneWidget);
    });

    testWidgets('P0-1-W2: MaterialApp 存在且使用 router 配置', (
      WidgetTester tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localStorageProvider.overrideWithValue(storage)],
          child: const MyApp(),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.routerConfig, isNotNull);
    });
  });
}
