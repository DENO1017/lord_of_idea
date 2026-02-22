import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lord_of_idea/core/di/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError(
    'Override with ProviderScope overrides in main() or tests.',
  );
});

/// 创建用于测试或 main 的 LocalStorageService（需先有 SharedPreferences）。
Future<LocalStorageService> createLocalStorageService() async {
  final prefs = await SharedPreferences.getInstance();
  return LocalStorageService(prefs);
}
