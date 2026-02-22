import 'package:flutter/material.dart';

class SharedJournalScreen extends StatelessWidget {
  const SharedJournalScreen({super.key, required this.journalId});

  final String journalId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Shared Journal $journalId',
          key: const Key('shared_journal_screen_title'),
        ),
      ),
    );
  }
}
