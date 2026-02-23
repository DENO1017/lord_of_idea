import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lord_of_idea/features/journal/data/journal_providers.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';
import 'package:lord_of_idea/shared/models/journal.dart';

/// 手帐列表页：卡片网格展示，支持创建、进入详情、删除（含确认）。
class JournalListScreen extends ConsumerWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final listAsync = ref.watch(journalListProvider);

    return Scaffold(
      body: listAsync.when(
        data: (List<Journal> journals) {
          if (journals.isEmpty) {
            return _EmptyState(
              createLabel: l10n.createJournal,
              onCreate: () => _showCreateDialog(context, ref, l10n),
            );
          }
          return _JournalGrid(
            journals: journals,
            onTap: (Journal j) => context.go('/journal/${j.id}'),
            onDelete: (Journal j) => _confirmDelete(context, ref, j, l10n),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object err, StackTrace _) =>
            Center(child: Text(err.toString())),
      ),
      floatingActionButton:
          listAsync.value != null && listAsync.value!.isNotEmpty
          ? FloatingActionButton.extended(
              key: const Key('journal_list_create_button'),
              onPressed: () => _showCreateDialog(context, ref, l10n),
              icon: const Icon(Icons.add),
              label: Text(l10n.createJournal),
            )
          : null,
    );
  }

  static Future<void> _showCreateDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(l10n.createJournal),
          content: TextField(
            key: const Key('journal_create_title_field'),
            controller: controller,
            decoration: InputDecoration(
              hintText: l10n.journalDefaultTitle,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (String value) => Navigator.of(ctx).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
            ),
          ],
        );
      },
    );
    if (result == null || !context.mounted) return;
    final title = result.isEmpty ? l10n.journalDefaultTitle : result;
    final repo = ref.read(journalRepositoryProvider);
    final journal = await repo.createJournal(title: title);
    ref.invalidate(journalListProvider);
    if (!context.mounted) return;
    context.go('/journal/${journal.id}');
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Journal journal,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(l10n.journalDeleteTitle),
          content: Text(l10n.journalDeleteConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
              ),
              child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(journalRepositoryProvider).deleteJournal(journal.id);
    ref.invalidate(journalListProvider);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.createLabel, required this.onCreate});

  final String createLabel;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton.icon(
            key: const Key('journal_list_create_button'),
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: Text(createLabel),
          ),
        ],
      ),
    );
  }
}

class _JournalGrid extends StatelessWidget {
  const _JournalGrid({
    required this.journals,
    required this.onTap,
    required this.onDelete,
  });

  final List<Journal> journals;
  final void Function(Journal) onTap;
  final void Function(Journal) onDelete;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: const Key('journal_list_grid'),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: journals.length,
      itemBuilder: (BuildContext context, int index) {
        final j = journals[index];
        return _JournalCard(
          journal: j,
          onTap: () => onTap(j),
          onDelete: () => onDelete(j),
        );
      },
    );
  }
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({
    required this.journal,
    required this.onTap,
    required this.onDelete,
  });

  final Journal journal;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onDelete,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: journal.coverPath != null && journal.coverPath!.isNotEmpty
                  ? Image.network(
                      journal.coverPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _coverPlaceholder(),
                    )
                  : _coverPlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                journal.title,
                key: Key('journal_card_title_${journal.id}'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.book, size: 48, color: Colors.grey),
    );
  }
}
