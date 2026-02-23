import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/features/divination/domain/services/poem_slip_service.dart';
import 'package:lord_of_idea/shared/models/poem_slip_result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('P1-4 诗签库数据与抽签服务', () {
    test('P1-4-U1: 加载默认库得到非空签条列表', () async {
      final service = PoemSlipService();
      final list = await service.loadLibrary(kDefaultPoemSlipLibraryId);
      expect(list, isNotEmpty);
    });

    test('P1-4-U2: 抽签（固定 Random）得到确定的一条 PoemSlipResult', () async {
      final service = PoemSlipService(random: Random(42));
      final result = await service.draw(kDefaultPoemSlipLibraryId);
      expect(result, isA<PoemSlipResult>());
      expect(result.type, PoemSlipResult.typeValue);
      expect(result.content, isNotEmpty);
    });

    test(
      'P1-4-U3: PoemSlipResult 含 libraryId、slipId、content、createdAt',
      () async {
        final service = PoemSlipService(random: Random(0));
        final result = await service.draw(kDefaultPoemSlipLibraryId);
        expect(result.libraryId, isNotEmpty);
        expect(result.libraryId, kDefaultPoemSlipLibraryId);
        expect(result.slipId, isNotEmpty);
        expect(result.content, isNotEmpty);
        expect(result.createdAt, isNotNull);
      },
    );
  });
}
