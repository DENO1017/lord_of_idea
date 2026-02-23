import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';

/// 工具聚合页：骰子、诗签、占卜入口（按钮形式排布），点击跳转对应子路由。
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  static const Key keyToolDice = Key('tools_entry_dice');
  static const Key keyToolPoemSlip = Key('tools_entry_poem_slip');
  static const Key keyToolTarot = Key('tools_entry_tarot');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navTools)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          FilledButton(
            key: keyToolDice,
            onPressed: () => context.go('/tools/dice'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(l10n.toolDice),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: keyToolPoemSlip,
            onPressed: () => context.go('/tools/poem-slip'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(l10n.toolPoemSlip),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: keyToolTarot,
            onPressed: () => context.go('/tools/tarot'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(l10n.toolTarot),
            ),
          ),
        ],
      ),
    );
  }
}
