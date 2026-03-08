import 'package:flutter/material.dart';

import '../models/vocabulary_item.dart';

class VocabularyItemCard extends StatelessWidget {
  final VocabularyItem item;
  final VoidCallback? onTap;
  final bool showExample;

  const VocabularyItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.showExample = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.germanWord,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.englishTranslation,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      item.partOfSpeech.isEmpty
                          ? 'Word'
                          : item.partOfSpeech,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: item.successRate.clamp(0.0, 100.0) / 100.0,
                      backgroundColor:
                          theme.colorScheme.surfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${item.successRate.toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              if (showExample && item.exampleSentence.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.exampleSentence,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  item.exampleTranslation,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

