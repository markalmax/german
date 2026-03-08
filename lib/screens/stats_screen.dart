import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/unit.dart';
import '../providers/stats_provider.dart';
import '../providers/vocab_provider.dart';
import '../utils/date_formatter.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/progress_indicator_widget.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Statistics'),
      ),
      body: FutureBuilder<void>(
        future: _loadData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Consumer2<StatsProvider, VocabProvider>(
            builder: (context, stats, vocab, _) {
              final sessions = stats.sessionsHistory;
              final unitStats = stats.unitStats;

              if (sessions.isEmpty && unitStats.isEmpty) {
                return const EmptyStateWidget(
                  title: 'No statistics yet',
                  message:
                      'Complete a quiz to start tracking your progress.',
                );
              }

              final overallScore = stats.getOverallScore();
              final totalQuizzes = stats.getTotalQuizzesCompleted();
              final avgTimePerQuestion =
                  stats.getAverageTimePerQuestion();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overall',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ProgressIndicatorWidget(
                                percentage: overallScore,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary,
                                label: 'Score',
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Quizzes completed: $totalQuizzes',
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Avg time/question: '
                                    '${avgTimePerQuestion.toStringAsFixed(1)}s',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Per unit',
                    style:
                        Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...unitStats.values.map((uStats) {
                    final Unit? unit =
                        vocab.getUnit(uStats.unitId);
                    return ListTile(
                      title: Text(unit?.name ?? 'Unit'),
                      subtitle: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Average score: '
                            '${uStats.averageScore.toStringAsFixed(1)}',
                          ),
                          if (uStats.lastAttemptDate != null)
                            Text(
                              'Last attempted: '
                              '${timeAgo(uStats.lastAttemptDate!)}',
                            ),
                        ],
                      ),
                      trailing: ProgressIndicatorWidget(
                        percentage: uStats.competencyLevel,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary,
                        label: 'Level',
                      ),
                      onTap: () {
                        if (unit != null) {
                          Navigator.of(context).pushNamed(
                            '/unit',
                            arguments: unit,
                          );
                        }
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  Text(
                    'Most missed words',
                    style:
                        Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder(
                    future: stats.getMostMissedWords(limit: 5),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(8),
                          child: LinearProgressIndicator(),
                        );
                      }
                      final items = snapshot.data ?? const [];
                      if (items.isEmpty) {
                        return Text(
                          'No missed words yet.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium,
                        );
                      }
                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: items
                            .map(
                              (item) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  '• ${item.germanWord} – ${item.englishTranslation}',
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Recent quizzes',
                    style:
                        Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...stats
                      .getRecentSessions(limit: 20)
                      .map((s) {
                    final unit = vocab.getUnit(s.unitId);
                    return ListTile(
                      title: Text(unit?.name ?? 'Unit'),
                      subtitle: Text(
                        'Score: ${s.score.toStringAsFixed(1)} • '
                        'Time: ${formatDuration(s.duration)}',
                      ),
                      trailing: Text(
                        formatDate(s.startTime),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _loadData(BuildContext context) async {
    await context.read<StatsProvider>().init();
    await context.read<VocabProvider>().init();
  }
}

