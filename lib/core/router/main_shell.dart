import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';

/// 主壳：底部五页签 + 内容区。用于 ShellRoute 的 builder。
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.state, required this.child});

  final GoRouterState state;
  final Widget child;

  static const List<String> _paths = <String>[
    '/home',
    '/tools',
    '/journal',
    '/market',
    '/me',
  ];

  int _selectedIndex(String location) {
    if (location == '/home') return 0;
    if (location.startsWith('/tools')) return 1;
    if (location == '/journal') return 2;
    if (location.startsWith('/market')) return 3;
    if (location.startsWith('/me')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = <String>[
      l10n.navHome,
      l10n.navTools,
      l10n.navJournal,
      l10n.navMarket,
      l10n.navMe,
    ];
    final currentIndex = _selectedIndex(state.matchedLocation);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        key: const Key('main_shell_bottom_nav'),
        currentIndex: currentIndex,
        onTap: (int index) {
          context.go(_paths[index]);
        },
        type: BottomNavigationBarType.fixed,
        items: List<BottomNavigationBarItem>.generate(
          5,
          (int i) => BottomNavigationBarItem(
            icon: Icon(_iconForIndex(i)),
            label: labels[i],
          ),
        ),
      ),
    );
  }

  IconData _iconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.build;
      case 2:
        return Icons.menu_book;
      case 3:
        return Icons.store;
      case 4:
        return Icons.person;
      default:
        return Icons.circle;
    }
  }
}
