import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lord_of_idea/features/divination/domain/services/poem_slip_service.dart';

/// 诗签加载与抽签服务。测试时可 override 为注入 [Random] 或 mock 的实例。
final poemSlipServiceProvider = Provider<PoemSlipService>(
  (ref) => PoemSlipService(),
);
