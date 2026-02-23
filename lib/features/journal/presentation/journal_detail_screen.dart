import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lord_of_idea/features/journal/data/journal_providers.dart';
import 'package:lord_of_idea/features/journal/presentation/journal_tool_insert_dialog.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';
import 'package:lord_of_idea/shared/models/dice_result.dart';
import 'package:lord_of_idea/shared/models/divination_result.dart';
import 'package:lord_of_idea/shared/models/journal.dart';
import 'package:lord_of_idea/shared/models/journal_block.dart';
import 'package:lord_of_idea/shared/models/journal_page.dart';
import 'package:lord_of_idea/shared/models/poem_slip_result.dart';

/// 手帐详情/阅读视图：按页切换，页签 N/Sum，块按类型展示；空页无占位文案。
class JournalDetailScreen extends ConsumerStatefulWidget {
  const JournalDetailScreen({super.key, required this.journalId, this.pageId});

  final String journalId;
  final String? pageId;

  @override
  ConsumerState<JournalDetailScreen> createState() =>
      _JournalDetailScreenState();
}

class _JournalDetailScreenState extends ConsumerState<JournalDetailScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final journalAsync = ref.watch(journalDetailProvider(widget.journalId));
    final pagesAsync = ref.watch(journalPagesProvider(widget.journalId));
    final l10n = AppLocalizations.of(context);

    return journalAsync.when(
      data: (Journal? journal) {
        if (journal == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/journal');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return pagesAsync.when(
          data: (List<JournalPage> pages) {
            final currentPage = _resolveCurrentPage(pages, widget.pageId);
            return Scaffold(
              appBar: AppBar(
                title: Text(journal.title),
                key: const Key('journal_detail_app_bar'),
                actions: [
                  IconButton(
                    key: const Key('journal_detail_edit_toggle'),
                    onPressed: () => setState(() => _isEditing = !_isEditing),
                    icon: Text(
                      _isEditing
                          ? (l10n?.journalRead ?? 'Read')
                          : (l10n?.journalEdit ?? 'Edit'),
                    ),
                  ),
                ],
              ),
              body: _buildBody(pages, currentPage, l10n),
            );
          },
          loading: () => Scaffold(
            appBar: AppBar(title: Text(journal.title)),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            appBar: AppBar(title: Text(journal.title)),
            body: Center(child: Text(e.toString())),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
    );
  }

  Widget _buildBody(
    List<JournalPage> pages,
    JournalPage? currentPage,
    AppLocalizations? l10n,
  ) {
    final isLandscape =
        MediaQuery.sizeOf(context).width > MediaQuery.sizeOf(context).height;
    final toolbar = _isEditing
        ? _EditToolbar(
            journalId: widget.journalId,
            pageId: currentPage?.id,
            l10n: l10n,
          )
        : null;

    Widget content = Column(
      children: [
        if (pages.isNotEmpty)
          _PageTabs(
            journalId: widget.journalId,
            pages: pages,
            currentPage: currentPage,
          ),
        Expanded(
          child: currentPage == null
              ? const SizedBox.shrink()
              : _PageBlocks(
                  pageId: currentPage.id,
                  isEditing: _isEditing,
                  journalId: widget.journalId,
                ),
        ),
      ],
    );

    if (toolbar == null) return content;
    if (isLandscape) {
      return Row(
        children: [
          Expanded(child: content),
          toolbar,
        ],
      );
    }
    return Column(
      children: [
        toolbar,
        Expanded(child: content),
      ],
    );
  }

  JournalPage? _resolveCurrentPage(List<JournalPage> pages, String? pageId) {
    if (pages.isEmpty) return null;
    if (pageId != null) {
      for (final p in pages) {
        if (p.id == pageId) return p;
      }
    }
    return pages.first;
  }
}

/// 编辑态工具栏：横版右侧、竖版上侧；P2-5 仅「添加块」，P2-6 补充骰子/诗签/占卜入口。
class _EditToolbar extends ConsumerWidget {
  const _EditToolbar({
    required this.journalId,
    required this.pageId,
    required this.l10n,
  });

  final String journalId;
  final String? pageId;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (pageId == null) return const SizedBox.shrink();
    final isLandscape =
        MediaQuery.sizeOf(context).width > MediaQuery.sizeOf(context).height;
    return Container(
      key: const Key('journal_detail_edit_toolbar'),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          left: isLandscape
              ? BorderSide(color: Theme.of(context).dividerColor)
              : BorderSide.none,
          top: isLandscape
              ? BorderSide.none
              : BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: isLandscape
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AddBlockButton(
                  journalId: journalId,
                  pageId: pageId!,
                  addBlockLabel: l10n?.journalAddBlock ?? 'Add block',
                ),
                const SizedBox(height: 8),
                _ToolbarDiceButton(
                  pageId: pageId!,
                  journalId: journalId,
                  l10n: l10n,
                ),
                _ToolbarPoemSlipButton(
                  pageId: pageId!,
                  journalId: journalId,
                  l10n: l10n,
                ),
                _ToolbarTarotButton(
                  pageId: pageId!,
                  journalId: journalId,
                  l10n: l10n,
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AddBlockButton(
                  journalId: journalId,
                  pageId: pageId!,
                  addBlockLabel: l10n?.journalAddBlock ?? 'Add block',
                ),
                const SizedBox(width: 8),
                _ToolbarDiceButton(
                  pageId: pageId!,
                  journalId: journalId,
                  l10n: l10n,
                ),
                _ToolbarPoemSlipButton(
                  pageId: pageId!,
                  journalId: journalId,
                  l10n: l10n,
                ),
                _ToolbarTarotButton(
                  pageId: pageId!,
                  journalId: journalId,
                  l10n: l10n,
                ),
              ],
            ),
    );
  }
}

class _AddBlockButton extends ConsumerWidget {
  const _AddBlockButton({
    required this.journalId,
    required this.pageId,
    required this.addBlockLabel,
  });

  final String journalId;
  final String pageId;
  final String addBlockLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      key: const Key('journal_detail_add_block'),
      onPressed: () => _showAddTextBlockDialog(
        context,
        ref,
        journalId: journalId,
        pageId: pageId,
        addBlockLabel: addBlockLabel,
      ),
      icon: const Icon(Icons.add),
      label: Text(addBlockLabel),
    );
  }
}

class _ToolbarDiceButton extends StatelessWidget {
  const _ToolbarDiceButton({
    required this.pageId,
    required this.journalId,
    required this.l10n,
  });

  final String pageId;
  final String journalId;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      key: const Key('journal_toolbar_dice'),
      onPressed: () => showJournalToolInsertDialog(
        context,
        pageId: pageId,
        journalId: journalId,
        toolType: 'dice',
        l10n: l10n,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.casino),
          const SizedBox(width: 8),
          Text(l10n?.toolDice ?? 'Dice'),
        ],
      ),
    );
  }
}

class _ToolbarPoemSlipButton extends StatelessWidget {
  const _ToolbarPoemSlipButton({
    required this.pageId,
    required this.journalId,
    required this.l10n,
  });

  final String pageId;
  final String journalId;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      key: const Key('journal_toolbar_poem_slip'),
      onPressed: () => showJournalToolInsertDialog(
        context,
        pageId: pageId,
        journalId: journalId,
        toolType: 'poem_slip',
        l10n: l10n,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book),
          const SizedBox(width: 8),
          Text(l10n?.toolPoemSlip ?? 'Poem Slip'),
        ],
      ),
    );
  }
}

class _ToolbarTarotButton extends StatelessWidget {
  const _ToolbarTarotButton({
    required this.pageId,
    required this.journalId,
    required this.l10n,
  });

  final String pageId;
  final String journalId;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      key: const Key('journal_toolbar_tarot'),
      onPressed: () => showJournalToolInsertDialog(
        context,
        pageId: pageId,
        journalId: journalId,
        toolType: 'divination',
        l10n: l10n,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.style),
          const SizedBox(width: 8),
          Text(l10n?.toolTarot ?? 'Tarot'),
        ],
      ),
    );
  }
}

Future<void> _showAddTextBlockDialog(
  BuildContext context,
  WidgetRef ref, {
  required String journalId,
  required String pageId,
  required String addBlockLabel,
}) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(addBlockLabel),
      content: TextField(
        key: const Key('journal_add_block_text_field'),
        controller: controller,
        decoration: InputDecoration(
          hintText: addBlockLabel,
          border: const OutlineInputBorder(),
        ),
        autofocus: true,
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    ),
  );
  if (result == null || !context.mounted) return;
  final editor = ref.read(blockEditorProvider);
  await editor.appendTextBlock(pageId, result.isEmpty ? '' : result);
  ref.invalidate(journalBlocksProvider(pageId));
  ref.invalidate(journalDetailProvider(journalId));
  ref.invalidate(journalListProvider);
}

class _PageTabs extends StatelessWidget {
  const _PageTabs({
    required this.journalId,
    required this.pages,
    required this.currentPage,
  });

  final String journalId;
  final List<JournalPage> pages;
  final JournalPage? currentPage;

  @override
  Widget build(BuildContext context) {
    final total = pages.length;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        key: const Key('journal_detail_page_tabs'),
        children: List.generate(total, (index) {
          final page = pages[index];
          final n = index + 1;
          final isCurrent = currentPage?.id == page.id;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ChoiceChip(
              label: Text('$n/$total'),
              selected: isCurrent,
              onSelected: (_) {
                context.go('/journal/$journalId/page/${page.id}');
              },
            ),
          );
        }),
      ),
    );
  }
}

class _PageBlocks extends ConsumerWidget {
  const _PageBlocks({
    required this.pageId,
    required this.isEditing,
    required this.journalId,
  });

  final String pageId;
  final bool isEditing;
  final String journalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocksAsync = ref.watch(journalBlocksProvider(pageId));
    return blocksAsync.when(
      data: (List<JournalBlock> blocks) {
        if (blocks.isEmpty && !isEditing) return const SizedBox.shrink();
        if (blocks.isEmpty && isEditing) {
          return ListView(
            key: const Key('journal_detail_blocks_list'),
            padding: const EdgeInsets.all(16),
          );
        }
        if (isEditing) {
          final editor = ref.read(blockEditorProvider);
          return ReorderableListView.builder(
            key: const Key('journal_detail_blocks_list'),
            padding: const EdgeInsets.all(16),
            itemCount: blocks.length,
            onReorder: (int oldIndex, int newIndex) async {
              if (oldIndex < newIndex) newIndex--;
              final reordered = List<JournalBlock>.from(blocks);
              final item = reordered.removeAt(oldIndex);
              reordered.insert(newIndex, item);
              await editor.reorderBlocks(
                pageId,
                reordered.map((b) => b.id).toList(),
              );
              ref.invalidate(journalBlocksProvider(pageId));
              ref.invalidate(journalDetailProvider(journalId));
              ref.invalidate(journalListProvider);
            },
            itemBuilder: (BuildContext context, int index) {
              final block = blocks[index];
              return Padding(
                key: Key('journal_block_${block.id}'),
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: index,
                      child: Icon(
                        Icons.drag_handle,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _BlockTile(block: block)),
                  ],
                ),
              );
            },
          );
        }
        return ListView.builder(
          key: const Key('journal_detail_blocks_list'),
          padding: const EdgeInsets.all(16),
          itemCount: blocks.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BlockTile(block: blocks[index]),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}

class _BlockTile extends StatelessWidget {
  const _BlockTile({required this.block});

  final JournalBlock block;

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case 'text':
        return _TextBlockView(payload: block.payload);
      case 'dice':
        return _DiceBlockView(payload: block.payload);
      case 'poem_slip':
        return _PoemSlipBlockView(payload: block.payload);
      case 'divination':
        return _DivinationBlockView(payload: block.payload);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _TextBlockView extends StatelessWidget {
  const _TextBlockView({required this.payload});

  final String payload;

  @override
  Widget build(BuildContext context) {
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final content = map['content'] as String? ?? '';
      return SelectableText(
        content,
        style: Theme.of(context).textTheme.bodyLarge,
        key: const Key('journal_block_text'),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}

class _DiceBlockView extends StatelessWidget {
  const _DiceBlockView({required this.payload});

  final String payload;

  @override
  Widget build(BuildContext context) {
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final result = DiceResult.fromJson(map);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        key: const Key('journal_block_dice'),
        children: [
          Text(
            result.expression,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text('${result.total}', style: Theme.of(context).textTheme.bodyLarge),
        ],
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}

class _PoemSlipBlockView extends StatelessWidget {
  const _PoemSlipBlockView({required this.payload});

  final String payload;

  @override
  Widget build(BuildContext context) {
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final result = PoemSlipResult.fromJson(map);
      return SelectableText(
        result.content,
        style: Theme.of(context).textTheme.bodyLarge,
        key: const Key('journal_block_poem_slip'),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}

/// 占卜块仅展示牌图，正逆位正确（逆位旋转 180°）。
class _DivinationBlockView extends StatelessWidget {
  const _DivinationBlockView({required this.payload});

  final String payload;

  static String _imagePath(DivinationResult r) =>
      r.imagePathOrUrl ?? 'assets/tarot/images/${r.cardId}.png';

  @override
  Widget build(BuildContext context) {
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final result = DivinationResult.fromJson(map);
      final path = _imagePath(result);
      final isNetwork = Uri.tryParse(path)?.hasAbsolutePath == true;
      Widget image = isNetwork
          ? Image.network(
              path,
              key: const Key('journal_block_divination_image'),
              width: 160,
              height: 280,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _placeholder(context),
            )
          : Image.asset(
              path,
              key: const Key('journal_block_divination_image'),
              width: 160,
              height: 280,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _placeholder(context),
            );
      if (result.reversed) {
        image = Transform.rotate(angle: math.pi, child: image);
      }
      return image;
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: 160,
      height: 280,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.style,
        size: 48,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
