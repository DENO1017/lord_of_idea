import 'package:flutter/material.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';

/// 市集占位页，路由 /market。
class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = l10n?.navMarket ?? 'Market';
    return Scaffold(
      body: Center(child: Text(label, key: const Key('market_screen_title'))),
    );
  }
}
