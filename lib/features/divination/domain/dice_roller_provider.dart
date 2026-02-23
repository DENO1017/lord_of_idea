import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lord_of_idea/features/divination/domain/services/dice_roller.dart';

/// 骰子解析与掷骰服务。测试时可 override 为 [DiceRoller]（注入 [Random] 种子）。
final diceRollerProvider = Provider<DiceRoller>((ref) => DiceRoller());
