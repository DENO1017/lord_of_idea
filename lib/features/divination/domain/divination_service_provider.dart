import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lord_of_idea/features/divination/domain/services/divination_service.dart';

/// 简易占卜（塔罗）抽牌服务。测试时可 override 为注入 [Random] 或 mock 的实例。
final divinationServiceProvider = Provider<DivinationService>(
  (ref) => DivinationService(),
);
