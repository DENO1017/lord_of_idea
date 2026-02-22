import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';

void main() {
  group('P0-8 国际化（l10n）', () {
    testWidgets('P0-8-U1: 生成类 AppLocalizations 存在且可实例化', (
      WidgetTester tester,
    ) async {
      const Key key = Key('l10n-builder');
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            key: key,
            builder: (BuildContext context) {
              final l10n = AppLocalizations.of(context);
              return Text(l10n!.settings);
            },
          ),
        ),
      );

      final BuildContext context = tester.element(find.byKey(key));
      expect(AppLocalizations.of(context), isNotNull);
    });

    testWidgets('P0-8-W1: locale 为 zh 时，某处显示中文文案（如「设置」）', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              return Text(AppLocalizations.of(context)!.settings);
            },
          ),
        ),
      );

      expect(find.text('设置'), findsOneWidget);
    });

    testWidgets('P0-8-W2: locale 为 en 时，同一 key 显示英文（如 "Settings"）', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              return Text(AppLocalizations.of(context)!.settings);
            },
          ),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
