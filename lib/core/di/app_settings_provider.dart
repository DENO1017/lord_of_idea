import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lord_of_idea/core/di/app_settings_notifier.dart';

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettingsState>(
      AppSettingsNotifier.new,
    );
