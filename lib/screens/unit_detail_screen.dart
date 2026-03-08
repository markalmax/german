import 'package:flutter/material.dart';

import '../models/unit.dart';
import '../widgets/vocabulary_item_card.dart';

class UnitDetailScreen extends StatefulWidget {
  final Unit unit;

  const UnitDetailScreen({super.key, required this.unit});

  @override
  State<UnitDetailScreen> createState() => _UnitDetailScreenState();
}

class _UnitDetailScreenState extends State<UnitDetailScreen> {
  late bool _showExamples;

  @override
  void initState() {
    super.initState();
    _showExamples = true;
  }

  void _startQuiz() {
    Navigator.of(context).pushNamed(
      '/quiz',
      arguments: widget.unit,
    );
  }

  void _editUnit() {
    Navigator.of(context).pushNamed(
      '/edit-unit',
      arguments: widget.unit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.unit;

    return Scaffold(
      appBar: AppBar(
        title: Text(unit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit unit',
            onPressed: _editUnit,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (unit.description.isNotEmpty) ...[
                  Text(
                    unit.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  '${unit.vocabularyItems.length} words',
                  style:
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              onPressed: _startQuiz,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Quiz'),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _showExamples
                      ? 'Hide examples'
                      : 'Show examples',
                ),
                Switch(
                  value: _showExamples,
                  onChanged: (v) {
                    setState(() => _showExamples = v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              itemCount: unit.vocabularyItems.length,
              itemBuilder: (context, index) {
                final item = unit.vocabularyItems[index];
                return VocabularyItemCard(
                  item: item,
                  showExample: _showExamples,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

