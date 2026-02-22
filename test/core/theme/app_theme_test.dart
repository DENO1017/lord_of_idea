import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lord_of_idea/core/theme/app_theme.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    AppTheme.useFallbackTextThemeForTesting = true;
  });

  group('AppTheme', () {
    group('P0-2-U1: lightTheme colorScheme.primary', () {
      test('lightTheme colorScheme.primary is #6B2D3C', () {
        expect(
          AppTheme.lightTheme.colorScheme.primary,
          const Color(0xFF6B2D3C),
        );
      });
    });

    group('P0-2-U2: darkTheme surface', () {
      test('darkTheme colorScheme.surface is #2C2620', () {
        expect(AppTheme.darkTheme.colorScheme.surface, const Color(0xFF2C2620));
      });
    });

    group('P0-2-U3: lightTheme textTheme', () {
      test('lightTheme textTheme exists and headlineLarge is non-null', () {
        final theme = AppTheme.lightTheme;
        expect(theme.textTheme.headlineLarge, isNotNull);
        expect(theme.textTheme.headlineLarge!.fontSize, 28);
      });
    });

    group('P0-2-W1: Widget receives light theme', () {
      testWidgets('child receives ThemeData with colorScheme.primary #6B2D3C', (
        WidgetTester tester,
      ) async {
        Color? capturedPrimary;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Builder(
              builder: (context) {
                capturedPrimary = Theme.of(context).colorScheme.primary;
                return const SizedBox();
              },
            ),
          ),
        );
        expect(capturedPrimary, const Color(0xFF6B2D3C));
      });
    });
  });
}
