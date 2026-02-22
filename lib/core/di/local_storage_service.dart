import 'package:shared_preferences/shared_preferences.dart';

/// 本地键值存储，封装 SharedPreferences，key 使用前缀 [keyPrefix]。
class LocalStorageService {
  LocalStorageService(this._prefs);

  static const String keyPrefix = 'lord_of_idea.';

  final SharedPreferences _prefs;

  String? getString(String key) => _prefs.getString(_fullKey(key));

  Future<void> setString(String key, String value) =>
      _prefs.setString(_fullKey(key), value);

  bool? getBool(String key) => _prefs.getBool(_fullKey(key));

  Future<void> setBool(String key, bool value) =>
      _prefs.setBool(_fullKey(key), value);

  String _fullKey(String key) =>
      key.startsWith(keyPrefix) ? key : '$keyPrefix$key';
}
