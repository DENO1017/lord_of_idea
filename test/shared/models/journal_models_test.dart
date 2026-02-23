import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/shared/models/journal.dart';

void main() {
  group('Journal', () {
    test('P2-1-U1: 含 id、title、createdAt、updatedAt；toJson/fromJson 往返', () {
      final createdAt = DateTime.utc(2026, 2, 23, 10, 0);
      final updatedAt = DateTime.utc(2026, 2, 23, 12, 0);
      final journal = Journal(
        id: 'j1',
        title: '测试手账',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
      final json = journal.toJson();
      final restored = Journal.fromJson(json);
      expect(restored.id, journal.id);
      expect(restored.title, journal.title);
      expect(restored.createdAt, journal.createdAt);
      expect(restored.updatedAt, journal.updatedAt);
    });

    test('P2-1-U1: toJson 含 ISO8601 时间字符串', () {
      final journal = Journal(
        id: 'j2',
        title: 'Title',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 2),
      );
      final json = journal.toJson();
      expect(json['createdAt'], '2026-01-01T00:00:00.000Z');
      expect(json['updatedAt'], '2026-01-02T00:00:00.000Z');
    });
  });
}
