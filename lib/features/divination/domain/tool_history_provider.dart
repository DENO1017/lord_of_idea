import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lord_of_idea/shared/models/dice_result.dart';
import 'package:lord_of_idea/shared/models/divination_result.dart';
import 'package:lord_of_idea/shared/models/poem_slip_result.dart';

/// 每类工具结果在历史中保留的最大条数。
const int kToolHistoryMaxPerType = 20;

/// 工具历史状态：骰子、诗签、占卜各自最近的结果列表（新在前）。
class ToolHistoryState {
  const ToolHistoryState({
    this.dice = const [],
    this.poemSlip = const [],
    this.divination = const [],
  });

  final List<DiceResult> dice;
  final List<PoemSlipResult> poemSlip;
  final List<DivinationResult> divination;

  ToolHistoryState copyWith({
    List<DiceResult>? dice,
    List<PoemSlipResult>? poemSlip,
    List<DivinationResult>? divination,
  }) {
    return ToolHistoryState(
      dice: dice ?? this.dice,
      poemSlip: poemSlip ?? this.poemSlip,
      divination: divination ?? this.divination,
    );
  }
}

/// 工具历史 Notifier：供手帐编辑态「从历史选择」与各工具页写入历史。
class ToolHistoryNotifier extends Notifier<ToolHistoryState> {
  @override
  ToolHistoryState build() => const ToolHistoryState();

  void addDice(DiceResult result) {
    final next = [result, ...state.dice];
    if (next.length > kToolHistoryMaxPerType) {
      state = state.copyWith(dice: next.sublist(0, kToolHistoryMaxPerType));
    } else {
      state = state.copyWith(dice: next);
    }
  }

  void addPoemSlip(PoemSlipResult result) {
    final next = [result, ...state.poemSlip];
    if (next.length > kToolHistoryMaxPerType) {
      state = state.copyWith(poemSlip: next.sublist(0, kToolHistoryMaxPerType));
    } else {
      state = state.copyWith(poemSlip: next);
    }
  }

  void addDivination(DivinationResult result) {
    final next = [result, ...state.divination];
    if (next.length > kToolHistoryMaxPerType) {
      state = state.copyWith(
        divination: next.sublist(0, kToolHistoryMaxPerType),
      );
    } else {
      state = state.copyWith(divination: next);
    }
  }
}

/// 工具历史 Provider。手帐编辑态工具栏读取以展示「从历史选择」；各工具页在保存/抽签时写入。
final toolHistoryProvider =
    NotifierProvider<ToolHistoryNotifier, ToolHistoryState>(
      ToolHistoryNotifier.new,
    );
