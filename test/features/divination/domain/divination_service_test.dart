import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/features/divination/domain/services/divination_service.dart';
import 'package:lord_of_idea/shared/models/divination_result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('P1-6 塔罗牌组数据与单张抽牌服务', () {
    test('P1-6-U1: 加载默认牌组得到 22 或 78 张牌', () async {
      final service = DivinationService();
      final deck = await service.loadDeck(kDefaultTarotDeckAsset);
      expect(deck, isNotEmpty);
      expect(deck.length, 78);
    });

    test(
      'P1-6-U2: 抽牌（固定 Random）得到 DivinationResult，含 cardId、reversed、meaning',
      () {
        final service = DivinationService(Random(42));
        final deck = [
          TarotCard(
            cardId: 'rws_00',
            cardName: '愚者',
            uprightMeaning: '正位文案',
            reversedMeaning: '逆位文案',
          ),
        ];
        final result = service.drawOne(deck, kDefaultDeckId);
        expect(result, isA<DivinationResult>());
        expect(result.type, DivinationResult.typeValue);
        expect(result.cardId, isNotEmpty);
        expect(result.meaning, isNotEmpty);
        expect(result.deckId, kDefaultDeckId);
        expect(result.cardName, '愚者');
      },
    );

    test('P1-6-U3: reversed 为 true 时 meaning 为逆位释义', () {
      const reversedMeaning = '抗拒改变、停滞或迟迟无法放手。需要接受转变。';
      final card = TarotCard(
        cardId: 'rws_13',
        cardName: '死神',
        uprightMeaning: '结束与转变、放下与重生。',
        reversedMeaning: reversedMeaning,
      );
      final deck = [card];
      int? seedForReversed;
      for (int s = 0; s < 10000; s++) {
        final service = DivinationService(Random(s));
        final result = service.drawOne(deck, 'rws');
        if (result.reversed) {
          seedForReversed = s;
          break;
        }
      }
      expect(seedForReversed, isNotNull, reason: '应存在某种子使 reversed 为 true');
      final service = DivinationService(Random(seedForReversed!));
      final result = service.drawOne(deck, 'rws');
      expect(result.reversed, isTrue);
      expect(result.meaning, reversedMeaning);
    });
  });
}
