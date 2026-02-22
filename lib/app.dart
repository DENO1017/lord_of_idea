import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lord_of_idea/core/di/app_settings_provider.dart';
import 'package:lord_of_idea/core/router/app_router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(appRouterProvider);
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: const [Locale('en'), Locale('zh')],
      localizationsDelegates: const [],
    );
  }
}
