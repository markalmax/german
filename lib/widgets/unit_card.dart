import 'package:flutter/material.dart';

import '../models/unit.dart';
import '../utils/date_formatter.dart';
import 'progress_indicator_widget.dart';

/// Reusable card displaying a summary of a vocabulary [Unit].
class UnitCard extends StatelessWidget {
  final Unit unit;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const UnitCard({
    super.key,
    required this.unit,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unit.name,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        if (unit.description.isNotEmpty)
                          Text(
                            unit.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ProgressIndicatorWidget(
                    percentage: unit.competencyLevel,
                    color: theme.colorScheme.primary,
                    label: 'Level',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    unit.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: unit.isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    unit.isCompleted ? 'Completed' : 'In progress',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    formatDate(unit.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit unit',
                        onPressed: onEdit,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete unit',
                        onPressed: onDelete,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

