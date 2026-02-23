import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import 'package:lord_of_idea/shared/models/divination_result.dart';

/// 默认牌组资源路径（韦特塔罗 RWS）。
const String kDefaultTarotDeckAsset = 'assets/tarot/rws.json';

/// 默认牌组 ID（与 [simple_divination_spec] 一致）。
const String kDefaultDeckId = 'rws';

/// 单张塔罗牌数据（含正逆位释义）。
class TarotCard {
  const TarotCard({
    required this.cardId,
    required this.cardName,
    required this.uprightMeaning,
    required this.reversedMeaning,
    this.imagePath,
  });

  final String cardId;
  final String cardName;
  final String uprightMeaning;
  final String reversedMeaning;
  final String? imagePath;

  static TarotCard fromJson(Map<String, dynamic> json) {
    return TarotCard(
      cardId: json['cardId'] as String,
      cardName: json['cardName'] as String,
      uprightMeaning: json['uprightMeaning'] as String,
      reversedMeaning: json['reversedMeaning'] as String,
      imagePath: json['imagePath'] as String?,
    );
  }
}

/// 简易占卜（单张塔罗）抽牌服务。
/// 支持从资源加载牌组、随机抽一张、随机正逆位；[Random] 可注入便于测试。
class DivinationService {
  DivinationService([Random? random]) : _random = random ?? Random();

  final Random _random;

  /// 从 [assetPath] 加载牌组，返回牌列表。
  /// 需在已注册的 Flutter 资源中（如 [kDefaultTarotDeckAsset]）。
  Future<List<TarotCard>> loadDeck(String assetPath) async {
    final String jsonStr = await rootBundle.loadString(assetPath);
    final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => TarotCard.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 从牌组 [deck] 中随机抽一张，随机正逆位，组装 [DivinationResult]。
  /// [deckId] 为牌组标识（如 [kDefaultDeckId]）；[random] 可传入以覆盖实例随机源（测试用）。
  DivinationResult drawOne(
    List<TarotCard> deck,
    String deckId, {
    Random? random,
  }) {
    if (deck.isEmpty) {
      throw StateError('牌组为空，无法抽牌');
    }
    final r = random ?? _random;
    final index = r.nextInt(deck.length);
    final card = deck[index];
    final reversed = r.nextBool();
    final meaning = reversed ? card.reversedMeaning : card.uprightMeaning;
    return DivinationResult(
      createdAt: DateTime.now().toUtc(),
      deckId: deckId,
      cardId: card.cardId,
      cardName: card.cardName,
      reversed: reversed,
      meaning: meaning,
      imagePathOrUrl: card.imagePath,
    );
  }
}
