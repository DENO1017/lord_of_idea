import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/core/di/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('P0-5 LocalStorageService', () {
    late SharedPreferences prefs;
    late LocalStorageService storage;

    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      prefs = await SharedPreferences.getInstance();
      storage = LocalStorageService(prefs);
    });

    test('P0-5-U1: setString 后 getString 返回相同值', () async {
      await storage.setString('lord_of_idea.theme_mode', 'dark');
      expect(storage.getString('lord_of_idea.theme_mode'), 'dark');
    });

    test('P0-5-U2: 未设置过的 key 返回 null', () {
      expect(storage.getString('lord_of_idea.unknown'), isNull);
    });

    test('P0-5-U3: setBool / getBool 行为一致', () async {
      await storage.setBool('lord_of_idea.first_launch_done', true);
      expect(storage.getBool('lord_of_idea.first_launch_done'), true);
    });

    test('P0-5-U4: key 使用约定前缀 lord_of_idea.', () async {
      await storage.setString('theme_mode', 'light');
      expect(prefs.getKeys(), contains('lord_of_idea.theme_mode'));
    });
  });
}
