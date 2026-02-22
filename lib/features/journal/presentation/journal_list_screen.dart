import 'package:flutter/material.dart';

class JournalListScreen extends StatelessWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Journal List', key: Key('journal_list_screen_title')),
      ),
    );
  }
}
