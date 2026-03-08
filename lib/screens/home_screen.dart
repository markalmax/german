import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/unit.dart';
import '../providers/stats_provider.dart';
import '../providers/vocab_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/unit_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openStats(BuildContext context) {
    Navigator.of(context).pushNamed('/stats');
  }

  void _openAddUnit(BuildContext context) {
    Navigator.of(context).pushNamed('/add-unit');
  }

  void _openUnitDetail(BuildContext context, Unit unit) {
    Navigator.of(context).pushNamed('/unit', arguments: unit);
  }

  void _editUnit(BuildContext context, Unit unit) {
    Navigator.of(context).pushNamed('/edit-unit', arguments: unit);
  }

  void _confirmDelete(BuildContext context, Unit unit) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete unit'),
        content: Text(
          'Are you sure you want to delete "${unit.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        context.read<VocabProvider>().deleteUnit(unit.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('German Vocabulary Quiz'),
        actions: [
          IconButton(
            onPressed: () => _openStats(context),
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Statistics',
          ),
        ],
      ),
      body: Consumer2<VocabProvider, StatsProvider>(
        builder: (context, vocab, stats, _) {
          if (vocab.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final units = vocab.getAllUnits();
          if (units.isEmpty) {
            return EmptyStateWidget(
              title: 'No units yet',
              message:
                  'Create your first unit to start learning German vocabulary.',
              action: () => _openAddUnit(context),
              actionLabel: 'Add Unit',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await vocab.init();
              await context.read<StatsProvider>().init();
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: units.length,
              itemBuilder: (context, index) {
                final unit = units[index];
                return GestureDetector(
                  onLongPress: () =>
                      _showUnitActionsSheet(context, unit),
                  child: UnitCard(
                    unit: unit,
                    onTap: () => _openUnitDetail(context, unit),
                    onEdit: () => _editUnit(context, unit),
                    onDelete: () => _confirmDelete(context, unit),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'statsFab',
            onPressed: () => _openStats(context),
            child: const Icon(Icons.bar_chart),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'addUnitFab',
            onPressed: () => _openAddUnit(context),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _showUnitActionsSheet(BuildContext context, Unit unit) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View unit'),
              onTap: () {
                Navigator.of(context).pop();
                _openUnitDetail(context, unit);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit unit'),
              onTap: () {
                Navigator.of(context).pop();
                _editUnit(context, unit);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete unit'),
              onTap: () {
                Navigator.of(context).pop();
                _confirmDelete(context, unit);
              },
            ),
          ],
        ),
      ),
    );
  }
}

