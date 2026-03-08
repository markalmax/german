import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/unit.dart';

class UnitCard extends StatelessWidget {
  final Unit unit;
  final VoidCallback onStartQuiz;
  final VoidCallback? onTap;

  const UnitCard({
    super.key,
    required this.unit,
    required this.onStartQuiz,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      unit.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (unit.isCustom)
                    Icon(
                      Icons.edit,
                      size: 18,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${unit.words.length} words',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onStartQuiz();
                  },
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text('Start Quiz'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
