import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lord_of_idea/features/divination/domain/dice_roller_provider.dart';
import 'package:lord_of_idea/features/divination/domain/services/dice_roller.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';
import 'package:lord_of_idea/shared/models/dice_result.dart';

/// 骰子工具页：表达式输入、快捷投掷、骰子盘、掷骰、结果与历史。路由 /tools/dice。
class DiceScreen extends ConsumerStatefulWidget {
  const DiceScreen({super.key});

  @override
  ConsumerState<DiceScreen> createState() => _DiceScreenState();
}

class _DiceScreenState extends ConsumerState<DiceScreen> {
  static const int _maxHistory = 100;
  static const List<int> _standardFaces = [4, 6, 8, 10, 12, 20];
  // 珠子修正：小=1，中=5，大=10（正/负各三种）
  static const List<int> _beadValues = [1, 5, 10];

  final TextEditingController _expressionController = TextEditingController();
  DiceRollResult? _lastResult;
  String? _lastExpression; // 用于重 Roll
  DiceResult? _pendingEntry; // 舍弃/重 Roll 仅保留最近一条
  final List<DiceResult> _savedHistory = [];
  // 骰子盘：面数 -> 数量（0..20）
  final Map<int, int> _diceCounts = {for (final f in _standardFaces) f: 0};
  // 珠子：+1,+5,+10,-1,-5,-10 -> 数量（0..20）
  final Map<int, int> _beadCounts = {
    for (final v in _beadValues) v: 0,
    for (final v in _beadValues) -v: 0,
  };

  @override
  void dispose() {
    _expressionController.dispose();
    super.dispose();
  }

  String _trayExpression() {
    int totalDice = 0;
    int? faces;
    for (final e in _diceCounts.entries) {
      if (e.value > 0) {
        if (faces != null && faces != e.key) return ''; // P1 仅单组
        faces = e.key;
        totalDice += e.value;
      }
    }
    if (totalDice == 0 || faces == null) {
      final mod = _trayModifier();
      if (mod == 0) return '';
      return mod > 0 ? '+$mod' : '$mod';
    }
    final mod = _trayModifier();
    final base = '${totalDice}d$faces';
    if (mod == 0) return base;
    return mod > 0 ? '$base+$mod' : '$base$mod';
  }

  int _trayModifier() {
    int sum = 0;
    for (final e in _beadCounts.entries) {
      sum += e.key * e.value;
    }
    return sum;
  }

  bool _isTrayValid() {
    final totalDice = _diceCounts.values.fold<int>(0, (a, b) => a + b);
    if (totalDice == 0) return false;
    if (totalDice > 20) return false;
    final mod = _trayModifier();
    if (mod < -999 || mod > 999) return false;
    return true;
  }

  void _onRoll(String expression) {
    final trimmed = expression.trim();
    if (trimmed.isEmpty) return;
    // 再次掷骰时，若当前已有结果且未点舍弃/重 Roll，则上一轮结果视为舍弃并写入历史（B-P1-1-002）
    setState(() {
      switch (_lastResult) {
        case DiceRollSuccess(result: final prev):
          _savedHistory.insert(0, prev);
          if (_savedHistory.length > _maxHistory) _savedHistory.removeLast();
          break;
        case DiceRollParseError():
        case null:
          break;
      }
    });
    final roller = ref.read(diceRollerProvider);
    final result = roller.roll(trimmed);
    setState(() {
      _lastResult = result;
      _lastExpression = trimmed;
    });
    switch (result) {
      case DiceRollParseError(:final message):
        _showParseErrorDialog(message);
        break;
      case DiceRollSuccess():
        break;
    }
  }

  void _showParseErrorDialog(String detail) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.invalidDice),
        content: Text(detail),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }

  void _onDiscard() {
    final r = _lastResult;
    if (r case DiceRollSuccess(result: final res)) {
      setState(() {
        _pendingEntry = res;
        _lastResult = null;
        _lastExpression = null;
      });
    }
  }

  void _onReRoll() {
    if (_lastExpression == null) return;
    _onRoll(_lastExpression!);
  }

  void _onSaveAndCopy(DiceResult diceResult) {
    _copyResult(diceResult);
    setState(() {
      _savedHistory.insert(0, diceResult);
      if (_savedHistory.length > _maxHistory) _savedHistory.removeLast();
      _lastResult = null;
      _lastExpression = null;
    });
  }

  void _promotePendingToSaved() {
    if (_pendingEntry == null) return;
    setState(() {
      _savedHistory.insert(0, _pendingEntry!);
      if (_savedHistory.length > _maxHistory) _savedHistory.removeLast();
      _pendingEntry = null;
    });
  }

  /// d100（2d10）时展示十位/个位；其余展示点数相加。
  String _formatRollsLine(DiceResult diceResult) {
    final expr = diceResult.expression.trim().toLowerCase();
    if (expr == '2d10' &&
        diceResult.rolls.length == 2 &&
        diceResult.modifier == null) {
      return '十位：${diceResult.rolls[0].value}，个位：${diceResult.rolls[1].value}';
    }
    return '点数：${diceResult.rolls.map((r) => r.value).join(' + ')}'
        '${diceResult.modifier != null ? ' ${diceResult.modifier! >= 0 ? '+' : ''}${diceResult.modifier}' : ''}';
  }

  /// 复制格式：无空格，表达式=总和（不含 rolls）。
  void _copyResult(DiceResult diceResult) {
    final text = '${diceResult.expression}=${diceResult.total}';
    Clipboard.setData(ClipboardData(text: text));
  }

  void _onConfirmTray() {
    final totalDice = _diceCounts.values.fold<int>(0, (a, b) => a + b);
    final mod = _trayModifier();
    final l10n = AppLocalizations.of(context)!;
    if (totalDice == 0) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.invalidDice),
          content: Text(l10n.diceCountZeroError),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        ),
      );
      return;
    }
    if (totalDice > 20) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.invalidDice),
          content: Text(l10n.diceCountOverMaxError),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        ),
      );
      return;
    }
    if (mod < -999 || mod > 999) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.invalidDice),
          content: const Text('修正值须在 -999～+999 之间'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        ),
      );
      return;
    }
    final expr = _trayExpression();
    if (expr.isNotEmpty) _onRoll(expr);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.toolDice)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // §5.1 界面上方展示当前组合表达式（骰子盘联动）
            Text(
              l10n.diceExpression,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              _trayExpression().isEmpty ? '—' : _trayExpression(),
              style: Theme.of(context).textTheme.titleMedium,
              key: const Key('dice_expression_display'),
            ),
            const SizedBox(height: 16),
            // 表达式输入
            TextField(
              key: const Key('dice_expression_input'),
              controller: _expressionController,
              decoration: InputDecoration(
                labelText: l10n.diceExpressionLabel,
                hintText: l10n.diceExpressionHint,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _onRoll(_expressionController.text),
            ),
            const SizedBox(height: 12),
            // §5.2 快捷投掷
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in _standardFaces)
                  FilledButton.tonal(
                    key: Key('dice_quick_$f'),
                    onPressed: () => _onRoll('d$f'),
                    child: Text('d$f'),
                  ),
                FilledButton.tonal(
                  key: const Key('dice_quick_d100'),
                  onPressed: () => _onRoll('2d10'),
                  child: Text(l10n.diceQuickD100),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // §5.3 骰子盘：标准骰数量
            Text('骰子', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            ..._standardFaces.map((f) {
              final count = _diceCounts[f]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    SizedBox(width: 36, child: Text('d$f')),
                    Expanded(
                      child: Slider(
                        value: count.toDouble(),
                        min: 0,
                        max: 20,
                        divisions: 20,
                        label: '$count',
                        onChanged: (v) {
                          setState(() {
                            final n = v.round();
                            if (n > 0) {
                              for (final k in _diceCounts.keys) {
                                _diceCounts[k] = k == f ? n : 0;
                              }
                            } else {
                              _diceCounts[f] = 0;
                            }
                          });
                        },
                      ),
                    ),
                    Text('$count'),
                  ],
                ),
              );
            }),
            // 珠子修正
            Text('修正（珠子）', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final v in _beadValues) ...[
                  _BeadChip(
                    label: '+$v',
                    color: Colors.red,
                    count: _beadCounts[v]!,
                    onChanged: (c) => setState(() => _beadCounts[v] = c),
                  ),
                  _BeadChip(
                    label: '-$v',
                    color: Colors.black87,
                    count: _beadCounts[-v]!,
                    onChanged: (c) => setState(() => _beadCounts[-v] = c),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('dice_confirm_tray'),
              onPressed: _isTrayValid() ? _onConfirmTray : null,
              child: Text(l10n.diceConfirm),
            ),
            const SizedBox(height: 24),
            // 掷骰按钮
            FilledButton.icon(
              key: const Key('dice_roll_button'),
              onPressed: () => _onRoll(_expressionController.text),
              icon: const Icon(Icons.casino),
              label: Text(l10n.diceRoll),
            ),
            const SizedBox(height: 24),
            if (_lastResult != null) _buildResult(context),
            const SizedBox(height: 16),
            _buildHistory(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final result = _lastResult!;
    switch (result) {
      case DiceRollSuccess(result: final diceResult):
        return _buildSuccessResult(diceResult);
      case DiceRollParseError():
        return const SizedBox.shrink();
    }
  }

  Widget _buildSuccessResult(DiceResult diceResult) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      key: const Key('dice_result_card'),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.diceExpression}：${diceResult.expression}'),
            Text(_formatRollsLine(diceResult)),
            Text(
              '${l10n.diceTotal}：${diceResult.total}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton(
                  key: const Key('dice_discard_button'),
                  onPressed: _onDiscard,
                  child: Text(l10n.diceDiscard),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  key: const Key('dice_reroll_button'),
                  onPressed: _onReRoll,
                  child: Text(l10n.diceReRoll),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  key: const Key('dice_save_copy_button'),
                  onPressed: () => _onSaveAndCopy(diceResult),
                  child: Text(l10n.diceSaveAndCopy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = <Widget>[];
    if (_pendingEntry != null) {
      items.add(
        _HistoryTile(
          result: _pendingEntry!,
          isPending: true,
          onCopy: _copyResult,
          onPromote: _promotePendingToSaved,
        ),
      );
    }
    for (final r in _savedHistory) {
      items.add(
        _HistoryTile(
          result: r,
          isPending: false,
          onCopy: _copyResult,
          onPromote: null,
        ),
      );
    }
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.diceHistory, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }
}

class _BeadChip extends StatelessWidget {
  const _BeadChip({
    required this.label,
    required this.color,
    required this.count,
    required this.onChanged,
  });

  final String label;
  final Color color;
  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label),
        const SizedBox(width: 4),
        IconButton.filled(
          iconSize: 18,
          onPressed: count < 20 ? () => onChanged(count + 1) : null,
          icon: const Icon(Icons.add),
        ),
        Text('$count'),
        IconButton.filled(
          iconSize: 18,
          onPressed: count > 0 ? () => onChanged(count - 1) : null,
          icon: const Icon(Icons.remove),
        ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.result,
    required this.isPending,
    required this.onCopy,
    this.onPromote,
  });

  final DiceResult result;
  final bool isPending;
  final void Function(DiceResult) onCopy;
  final VoidCallback? onPromote;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('${result.expression}=${result.total}'),
        subtitle: isPending ? const Text('（可编辑为保存）') : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => onCopy(result),
            ),
            if (onPromote != null)
              TextButton(onPressed: onPromote, child: const Text('保存')),
          ],
        ),
      ),
    );
  }
}
