import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/quiz_session.dart';
import '../providers/stats_provider.dart';
import '../providers/vocab_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: FutureBuilder<void>(
        future: _loadData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Consumer2<StatsProvider, VocabProvider>(
            builder: (context, stats, vocab, _) {
              final allStats = stats.statsByUnit;
              final sessions = stats.sessions;

              if (allStats.isEmpty && sessions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No quiz sessions yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete a quiz to see your stats',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (allStats.isNotEmpty) ...[
                    Text(
                      'Best scores by unit',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...allStats.values.map((s) {
                      final unit = vocab.getUnitById(s.unitId);
                      return _StatsCard(
                        unitName: unit?.name ?? s.unitId,
                        bestScore: s.bestScore,
                        bestTime: s.bestTime,
                        totalSessions: s.totalSessions,
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    'Recent sessions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...sessions.take(20).map((s) => _SessionTile(
                        session: s,
                        unitName: vocab.getUnitById(s.unitId)?.name ?? s.unitId,
                      )),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _loadData(BuildContext context) async {
    final stats = context.read<StatsProvider>();
    final vocab = context.read<VocabProvider>();
    await Future.wait([
      stats.loadAllStats(),
      stats.loadSessions(limit: 50),
      if (!vocab.isLoaded) vocab.loadUnits(),
    ]);
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.unitName,
    required this.bestScore,
    required this.bestTime,
    required this.totalSessions,
  });

  final String unitName;
  final int bestScore;
  final int bestTime;
  final int totalSessions;

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              unitName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatChip(
                  icon: Icons.check_circle,
                  label: 'Best: $bestScore',
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.timer,
                  label: _formatDuration(bestTime),
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.history,
                  label: '$totalSessions sessions',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
      label: Text(label, style: Theme.of(context).textTheme.bodySmall),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.unitName,
  });

  final QuizSession session;
  final String unitName;

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = session.totalAttempts > 0
        ? (session.correctCount / session.totalAttempts * 100).round()
        : 0;

    return ListTile(
      title: Text(unitName),
      subtitle: Text(
        '${session.correctCount} correct • $accuracy% • ${_formatDuration(session.durationSeconds)}',
      ),
      trailing: Text(
        _formatDate(session.timestamp),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
