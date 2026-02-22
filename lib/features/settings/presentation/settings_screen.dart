import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lord_of_idea/core/di/app_settings_provider.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        key: const Key('settings_screen_title'),
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          _sectionTitle(l10n.theme),
          ListTile(
            title: Text(l10n.themeLight),
            trailing: settings.themeMode == ThemeMode.light
                ? const Icon(Icons.check)
                : null,
            onTap: () => notifier.setThemeMode(ThemeMode.light),
          ),
          ListTile(
            title: Text(l10n.themeDark),
            trailing: settings.themeMode == ThemeMode.dark
                ? const Icon(Icons.check)
                : null,
            onTap: () => notifier.setThemeMode(ThemeMode.dark),
          ),
          ListTile(
            title: Text(l10n.themeSystem),
            trailing: settings.themeMode == ThemeMode.system
                ? const Icon(Icons.check)
                : null,
            onTap: () => notifier.setThemeMode(ThemeMode.system),
          ),
          _sectionTitle(l10n.language),
          ListTile(
            title: Text(l10n.languageZh),
            trailing: settings.locale?.languageCode == 'zh'
                ? const Icon(Icons.check)
                : null,
            onTap: () => notifier.setLocale(const Locale('zh')),
          ),
          ListTile(
            title: Text(l10n.languageEn),
            trailing: settings.locale?.languageCode == 'en'
                ? const Icon(Icons.check)
                : null,
            onTap: () => notifier.setLocale(const Locale('en')),
          ),
          ListTile(
            title: Text(l10n.themeSystem),
            trailing: settings.locale == null ? const Icon(Icons.check) : null,
            onTap: () => notifier.setLocale(null),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
