import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 应用主题：复古中世纪风格，色板、字体、间距与圆角符合 [theme_spec](https://docs/design/theme_spec)。
abstract final class AppTheme {
  AppTheme._();

  /// 测试用：为 true 时不加载 Google Fonts，使用回退 TextTheme。
  static bool _useFallbackTextTheme = false;
  static set useFallbackTextThemeForTesting(bool value) =>
      _useFallbackTextTheme = value;

  /// 浅色色板：酒红、金棕、羊皮纸背景。
  static ColorScheme get _lightColorScheme {
    const primary = Color(0xFF6B2D3C);
    const onPrimary = Color(0xFFFFFFFF);
    const primaryContainer = Color(0xFFE8D5D0);
    const onPrimaryContainer = Color(0xFF2D1519);
    const secondary = Color(0xFF8B7355);
    const onSecondary = Color(0xFFFFFFFF);
    const secondaryContainer = Color(0xFFF5E6C8);
    const onSecondaryContainer = Color(0xFF2D2518);
    const surface = Color(0xFFEDE4D8);
    const onSurface = Color(0xFF1C1916);
    const onSurfaceVariant = Color(0xFF4A4238);
    const error = Color(0xFF722F37);
    const onError = Color(0xFFFFFFFF);
    const errorContainer = Color(0xFFF5D5D5);
    const onErrorContainer = Color(0xFF2D1519);
    const outline = Color(0xFF6B5B4F);
    const outlineVariant = Color(0xFFB8A99A);
    const surfaceDim = Color(0xFFDDD0C0);
    const surfaceBright = Color(0xFFEDE4D8);
    const surfaceContainerLowest = Color(0xFFF4E9DC);
    const surfaceContainerLow = Color(0xFFF4E9DC);
    const surfaceContainer = Color(0xFFEDE4D8);
    const surfaceContainerHigh = Color(0xFFE8DFD3);
    const surfaceContainerHighest = Color(0xFFE2D9CD);
    return ColorScheme.light(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: secondary,
      onTertiary: onSecondary,
      tertiaryContainer: secondaryContainer,
      onTertiaryContainer: onSecondaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceContainerHighest,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainer: surfaceContainer,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceDim: surfaceDim,
      surfaceBright: surfaceBright,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: const Color(0xFF31302C),
      onInverseSurface: const Color(0xFFF5EFE7),
      inversePrimary: const Color(0xFFE8B8B0),
    );
  }

  /// 深色色板：暖褐基调。
  static ColorScheme get _darkColorScheme {
    const primary = Color(0xFFC9A9A0);
    const onPrimary = Color(0xFF3D2529);
    const primaryContainer = Color(0xFF5D3D44);
    const onPrimaryContainer = Color(0xFFE8D5D0);
    const secondary = Color(0xFFB8A088);
    const onSecondary = Color(0xFF2D2518);
    const secondaryContainer = Color(0xFF4A3E2D);
    const onSecondaryContainer = Color(0xFFF5E6C8);
    const surface = Color(0xFF2C2620);
    const onSurface = Color(0xFFEDE4D8);
    const onSurfaceVariant = Color(0xFFDDD0C0);
    const error = Color(0xFFE8B4B4);
    const onError = Color(0xFF4D1F24);
    const errorContainer = Color(0xFF722F37);
    const onErrorContainer = Color(0xFFF5D5D5);
    const outline = Color(0xFF6B5B4F);
    const outlineVariant = Color(0xFF4A4238);
    const surfaceDim = Color(0xFF1C1916);
    const surfaceBright = Color(0xFF363029);
    const surfaceContainerLowest = Color(0xFF1C1916);
    const surfaceContainerLow = Color(0xFF252019);
    const surfaceContainer = Color(0xFF2C2620);
    const surfaceContainerHigh = Color(0xFF363029);
    const surfaceContainerHighest = Color(0xFF413B33);
    return ColorScheme.dark(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: secondary,
      onTertiary: onSecondary,
      tertiaryContainer: secondaryContainer,
      onTertiaryContainer: onSecondaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceContainerHighest,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainer: surfaceContainer,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceDim: surfaceDim,
      surfaceBright: surfaceBright,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: const Color(0xFFEDE4D8),
      onInverseSurface: const Color(0xFF31302C),
      inversePrimary: const Color(0xFF6B2D3C),
    );
  }

  static const double _spacingUnit = 8.0;
  static const double _pagePadding = 24.0;
  static const double _cardRadius = 8.0;
  static const double _buttonRadius = 6.0;

  /// 浅色主题。
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      textTheme: _buildTextTheme(Brightness.light),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
        ),
      ),
    );
    return base;
  }

  /// 深色主题。
  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      textTheme: _buildTextTheme(Brightness.dark),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
        ),
      ),
    );
    return base;
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    if (_useFallbackTextTheme) return _fallbackTextTheme();
    final cinzel = GoogleFonts.cinzel();
    final cormorant = GoogleFonts.cormorantGaramond();
    return TextTheme(
      displayLarge: cinzel.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
      headlineLarge: cinzel.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
      headlineMedium: cinzel.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: cinzel.copyWith(fontSize: 20, fontWeight: FontWeight.w500),
      titleLarge: cinzel.copyWith(fontSize: 20, fontWeight: FontWeight.w500),
      titleMedium: cinzel.copyWith(fontSize: 18, fontWeight: FontWeight.w500),
      titleSmall: cinzel.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: cormorant.copyWith(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: cormorant.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: cormorant.copyWith(fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: cormorant.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: cormorant.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: cormorant.copyWith(fontSize: 12, fontWeight: FontWeight.w400),
    );
  }

  /// 测试用回退 TextTheme（不触发 Google Fonts 加载）。
  static TextTheme _fallbackTextTheme() {
    const bold28 = TextStyle(fontSize: 28, fontWeight: FontWeight.w700);
    const medium20 = TextStyle(fontSize: 20, fontWeight: FontWeight.w500);
    const medium18 = TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
    const regular16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
    const regular14 = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
    const regular12 = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
    return TextTheme(
      displayLarge: bold28,
      headlineLarge: bold28,
      headlineMedium: bold28.copyWith(fontSize: 24),
      headlineSmall: medium20,
      titleLarge: medium20,
      titleMedium: medium18,
      titleSmall: medium18.copyWith(fontSize: 16),
      bodyLarge: regular16,
      bodyMedium: regular14,
      bodySmall: regular12,
      labelLarge: regular14.copyWith(fontWeight: FontWeight.w500),
      labelMedium: regular12.copyWith(fontWeight: FontWeight.w500),
      labelSmall: regular12,
    );
  }

  /// 基准间距单位（8.0）。
  static double get spacingUnit => _spacingUnit;

  /// 页面边距（24.0）。
  static double get pagePadding => _pagePadding;

  /// 卡片圆角（8.0）。
  static double get cardRadius => _cardRadius;

  /// 按钮圆角（6.0）。
  static double get buttonRadius => _buttonRadius;
}
