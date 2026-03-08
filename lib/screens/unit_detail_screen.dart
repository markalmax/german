import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/unit.dart';
import '../providers/vocab_provider.dart';
import 'add_edit_unit_screen.dart';
import 'quiz_screen.dart';

class UnitDetailScreen extends StatelessWidget {
  final Unit unit;

  const UnitDetailScreen({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(unit.name),
        actions: [
          if (unit.isCustom) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToEdit(context),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context),
              tooltip: 'Delete',
            ),
          ],
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: () => _navigateToQuiz(context),
              icon: const Icon(Icons.play_arrow, size: 24),
              label: const Text('Start Quiz'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${unit.words.length} words',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: unit.words.length,
              itemBuilder: (context, index) {
                final word = unit.words[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(word.native),
                    subtitle: Text(word.target),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToQuiz(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizScreen(unit: unit),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditUnitScreen(unit: unit),
      ),
    ).then((_) {
      if (context.mounted) {
        final vocab = context.read<VocabProvider>();
        vocab.loadUnits();
      }
    });
  }

  void _confirmDelete(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Unit'),
        content: Text(
          'Are you sure you want to delete "${unit.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<VocabProvider>().deleteUnit(unit.id);
        Navigator.of(context).pop();
      }
    });
  }
}
