import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lord_of_idea/features/divination/domain/dice_roller_provider.dart';
import 'package:lord_of_idea/features/divination/domain/divination_service_provider.dart';
import 'package:lord_of_idea/features/divination/domain/poem_slip_service_provider.dart';
import 'package:lord_of_idea/features/divination/domain/services/divination_service.dart'
    show kDefaultDeckId, kDefaultTarotDeckAsset;
import 'package:lord_of_idea/features/divination/domain/services/dice_roller.dart';
import 'package:lord_of_idea/features/divination/domain/tool_history_provider.dart';
import 'package:lord_of_idea/features/divination/domain/services/poem_slip_service.dart'
    show kDefaultPoemSlipLibraryId;
import 'package:lord_of_idea/features/divination/presentation/poem_slip_screen.dart'
    show kPoemSlipLibraryIds;
import 'package:lord_of_idea/features/journal/data/journal_providers.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';
import 'package:lord_of_idea/shared/models/dice_result.dart';
import 'package:lord_of_idea/shared/models/divination_result.dart';
import 'package:lord_of_idea/shared/models/poem_slip_result.dart';
import 'package:lord_of_idea/shared/models/tool_result.dart';

/// 工具类型：骰子、诗签、占卜。
enum _ToolType { dice, poemSlip, divination }

/// 展示「从历史选择」与「现场使用」，插入选中或新产生的结果到当前页。
Future<void> showJournalToolInsertDialog(
  BuildContext context, {
  required String pageId,
  required String journalId,
  required String toolType,
  required AppLocalizations? l10n,
}) async {
  final type = switch (toolType) {
    'dice' => _ToolType.dice,
    'poem_slip' => _ToolType.poemSlip,
    'divination' => _ToolType.divination,
    _ => null,
  };
  if (type == null) return;
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => Consumer(
      builder: (ctx, ref, _) => _ToolInsertDialogContent(
        pageId: pageId,
        journalId: journalId,
        toolType: type,
        l10n: l10n,
        onInsert: (result) {
          final editor = ref.read(blockEditorProvider);
          editor.insertToolResultBlock(pageId, result);
          ref.invalidate(journalBlocksProvider(pageId));
          ref.invalidate(journalDetailProvider(journalId));
          ref.invalidate(journalListProvider);
          Navigator.of(ctx).pop();
        },
      ),
    ),
  );
}

class _ToolInsertDialogContent extends ConsumerStatefulWidget {
  const _ToolInsertDialogContent({
    required this.pageId,
    required this.journalId,
    required this.toolType,
    required this.l10n,
    required this.onInsert,
  });

  final String pageId;
  final String journalId;
  final _ToolType toolType;
  final AppLocalizations? l10n;
  final void Function(ToolResult result) onInsert;

  @override
  ConsumerState<_ToolInsertDialogContent> createState() =>
      _ToolInsertDialogContentState();
}

class _ToolInsertDialogContentState
    extends ConsumerState<_ToolInsertDialogContent> {
  @override
  Widget build(BuildContext context) {
    final history = ref.watch(toolHistoryProvider);
    final fromHistoryLabel =
        widget.l10n?.journalToolFromHistory ?? 'From history';
    final useLiveLabel = widget.l10n?.journalToolUseLive ?? 'Use now';

    List<Widget> historyItems = [];
    switch (widget.toolType) {
      case _ToolType.dice:
        historyItems = history.dice
            .map(
              (r) => ListTile(
                key: Key(
                  'journal_tool_history_dice_${r.expression}_${r.total}',
                ),
                title: Text('${r.expression}=${r.total}'),
                onTap: () => widget.onInsert(r),
              ),
            )
            .toList();
        break;
      case _ToolType.poemSlip:
        historyItems = history.poemSlip
            .map(
              (r) => ListTile(
                key: Key('journal_tool_history_poem_${r.slipId}'),
                title: Text(
                  r.content.length > 40
                      ? '${r.content.substring(0, 40)}…'
                      : r.content,
                ),
                onTap: () => widget.onInsert(r),
              ),
            )
            .toList();
        break;
      case _ToolType.divination:
        historyItems = history.divination
            .map(
              (r) => ListTile(
                key: Key('journal_tool_history_divination_${r.cardId}'),
                title: Text(r.cardName),
                onTap: () => widget.onInsert(r),
              ),
            )
            .toList();
        break;
    }

    return AlertDialog(
      title: Text(_title(widget.toolType, widget.l10n)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              fromHistoryLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            if (historyItems.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _emptyHistoryLabel(widget.toolType, widget.l10n),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: historyItems,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(useLiveLabel, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            FilledButton(
              key: Key('journal_tool_use_live_${widget.toolType.name}'),
              onPressed: () => _useLive(context),
              child: Text(useLiveLabel),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
      ],
    );
  }

  String _title(_ToolType t, AppLocalizations? l10n) {
    return switch (t) {
      _ToolType.dice => l10n?.toolDice ?? 'Dice',
      _ToolType.poemSlip => l10n?.toolPoemSlip ?? 'Poem Slip',
      _ToolType.divination => l10n?.toolTarot ?? 'Tarot',
    };
  }

  String _emptyHistoryLabel(_ToolType t, AppLocalizations? l10n) {
    return switch (t) {
      _ToolType.dice => 'No dice history. Use "Use now" to roll.',
      _ToolType.poemSlip => 'No poem slip history. Use "Use now" to draw.',
      _ToolType.divination => 'No divination history. Use "Use now" to draw.',
    };
  }

  Future<void> _useLive(BuildContext context) async {
    switch (widget.toolType) {
      case _ToolType.dice:
        await _useLiveDice(context);
        break;
      case _ToolType.poemSlip:
        await _useLivePoemSlip(context);
        break;
      case _ToolType.divination:
        await _useLiveDivination(context);
        break;
    }
  }

  Future<void> _useLiveDice(BuildContext context) async {
    final controller = TextEditingController(text: 'd6');
    final result = await showDialog<DiceResult>(
      context: context,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          return _DiceLiveDialog(
            controller: controller,
            l10n: widget.l10n,
            onRoll: () {
              final roller = ref.read(diceRollerProvider);
              final r = roller.roll(controller.text.trim());
              return switch (r) {
                DiceRollSuccess(:final result) => result,
                DiceRollParseError() => null,
              };
            },
          );
        },
      ),
    );
    if (result != null && context.mounted) {
      ref.read(toolHistoryProvider.notifier).addDice(result);
      widget.onInsert(result);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _useLivePoemSlip(BuildContext context) async {
    String libraryId = kDefaultPoemSlipLibraryId;
    final result = await showDialog<PoemSlipResult>(
      context: context,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          return _PoemSlipLiveDialog(
            initialLibraryId: libraryId,
            l10n: widget.l10n,
            onDraw: (String id) async {
              final service = ref.read(poemSlipServiceProvider);
              return service.draw(id);
            },
          );
        },
      ),
    );
    if (result != null && context.mounted) {
      ref.read(toolHistoryProvider.notifier).addPoemSlip(result);
      widget.onInsert(result);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _useLiveDivination(BuildContext context) async {
    final result = await showDialog<DivinationResult>(
      context: context,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) => _DivinationLiveDialog(
          l10n: widget.l10n,
          onDraw: () async {
            final service = ref.read(divinationServiceProvider);
            final deck = await service.loadDeck(kDefaultTarotDeckAsset);
            return service.drawOne(deck, kDefaultDeckId);
          },
        ),
      ),
    );
    if (result != null && context.mounted) {
      ref.read(toolHistoryProvider.notifier).addDivination(result);
      widget.onInsert(result);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

class _DiceLiveDialog extends StatefulWidget {
  const _DiceLiveDialog({
    required this.controller,
    required this.l10n,
    required this.onRoll,
  });

  final TextEditingController controller;
  final AppLocalizations? l10n;
  final DiceResult? Function() onRoll;

  @override
  State<_DiceLiveDialog> createState() => _DiceLiveDialogState();
}

class _DiceLiveDialogState extends State<_DiceLiveDialog> {
  DiceResult? _result;
  String? _error;

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.l10n?.toolDice ?? 'Dice'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('journal_tool_dice_expression'),
            controller: widget.controller,
            decoration: InputDecoration(
              labelText: widget.l10n?.diceExpressionLabel ?? 'Expression',
              hintText: widget.l10n?.diceExpressionHint ?? 'e.g. 2d6+3',
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _roll(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 12),
            Text('${_result!.expression}=${_result!.total}'),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          key: const Key('journal_tool_dice_roll'),
          onPressed: _roll,
          child: Text(widget.l10n?.diceRoll ?? 'Roll'),
        ),
        if (_result != null)
          FilledButton(
            key: const Key('journal_tool_dice_insert'),
            onPressed: () => Navigator.of(context).pop(_result),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
      ],
    );
  }

  void _roll() {
    setState(() {
      _error = null;
      _result = widget.onRoll();
      if (_result == null) {
        _error = widget.l10n?.invalidDice ?? 'Invalid expression';
      }
    });
  }
}

class _PoemSlipLiveDialog extends StatefulWidget {
  const _PoemSlipLiveDialog({
    required this.initialLibraryId,
    required this.l10n,
    required this.onDraw,
  });

  final String initialLibraryId;
  final AppLocalizations? l10n;
  final Future<PoemSlipResult> Function(String libraryId) onDraw;

  @override
  State<_PoemSlipLiveDialog> createState() => _PoemSlipLiveDialogState();
}

class _PoemSlipLiveDialogState extends State<_PoemSlipLiveDialog> {
  late String _libraryId;
  bool _loading = false;
  PoemSlipResult? _result;

  @override
  void initState() {
    super.initState();
    _libraryId = widget.initialLibraryId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.l10n?.toolPoemSlip ?? 'Poem Slip'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            key: const Key('journal_tool_poem_library'),
            initialValue: _libraryId,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: kPoemSlipLibraryIds
                .map(
                  (id) => DropdownMenuItem(
                    value: id,
                    child: Text(_libraryDisplayName(id)),
                  ),
                )
                .toList(),
            onChanged: _loading
                ? null
                : (v) {
                    if (v != null) setState(() => _libraryId = v);
                  },
          ),
          if (_result != null) ...[
            const SizedBox(height: 12),
            SelectableText(_result!.content),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          key: const Key('journal_tool_poem_draw'),
          onPressed: _loading ? null : _draw,
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.l10n?.poemSlipDraw ?? 'Draw'),
        ),
        if (_result != null)
          FilledButton(
            key: const Key('journal_tool_poem_insert'),
            onPressed: () => Navigator.of(context).pop(_result),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
      ],
    );
  }

  String _libraryDisplayName(String id) {
    if (id == kDefaultPoemSlipLibraryId) {
      return widget.l10n?.poemSlipLibraryMazu ?? 'Mazu Oracle';
    }
    return id;
  }

  Future<void> _draw() async {
    setState(() => _loading = true);
    try {
      final r = await widget.onDraw(_libraryId);
      if (mounted) {
        setState(() {
          _result = r;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}

class _DivinationLiveDialog extends StatefulWidget {
  const _DivinationLiveDialog({required this.l10n, required this.onDraw});

  final AppLocalizations? l10n;
  final Future<DivinationResult> Function() onDraw;

  @override
  State<_DivinationLiveDialog> createState() => _DivinationLiveDialogState();
}

class _DivinationLiveDialogState extends State<_DivinationLiveDialog> {
  bool _loading = false;
  DivinationResult? _result;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.l10n?.toolTarot ?? 'Tarot'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_result != null) ...[
            Text(_result!.cardName),
            Text(
              _result!.reversed
                  ? (widget.l10n?.tarotReversed ?? 'Reversed')
                  : (widget.l10n?.tarotUpright ?? 'Upright'),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          key: const Key('journal_tool_tarot_draw'),
          onPressed: _loading ? null : _draw,
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.l10n?.tarotDraw ?? 'Draw'),
        ),
        if (_result != null)
          FilledButton(
            key: const Key('journal_tool_tarot_insert'),
            onPressed: () => Navigator.of(context).pop(_result),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
      ],
    );
  }

  Future<void> _draw() async {
    setState(() => _loading = true);
    try {
      final r = await widget.onDraw();
      if (mounted) {
        setState(() {
          _result = r;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }
}
