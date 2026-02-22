import 'package:flutter/material.dart';

class JournalDetailScreen extends StatelessWidget {
  const JournalDetailScreen({super.key, required this.journalId, this.pageId});

  final String journalId;
  final String? pageId;

  @override
  Widget build(BuildContext context) {
    final subtitle = pageId != null ? ' / page $pageId' : '';
    return Scaffold(
      body: Center(
        child: Text(
          'Journal $journalId$subtitle',
          key: const Key('journal_detail_screen_title'),
        ),
      ),
    );
  }
}
