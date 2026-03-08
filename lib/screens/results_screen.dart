import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/quiz_question.dart';
import '../models/quiz_session.dart';
import '../models/unit.dart';
import '../providers/vocab_provider.dart';
import '../utils/date_formatter.dart';
import '../utils/score_calculator.dart';
import '../widgets/score_display_widget.dart';

class ResultsScreen extends StatelessWidget {
  final QuizSession session;
  final bool isNewBest;

  const ResultsScreen({
    super.key,
    required this.session,
    required this.isNewBest,
  });

  @override
  Widget build(BuildContext context) {
    final score = session.score;
    final rating = getScoreRating(score);
    final message = getPerformanceMessage(score);
    final durationText = formatDuration(session.duration);

    final byType = <QuizQuestionType, int>{};
    for (final type in QuizQuestionType.values) {
      byType[type] = 0;
    }
    for (final answer in session.answers) {
      if (!answer.isCorrect) continue;
      final question = session.questions
          .firstWhere((q) => q.id == answer.questionId);
      byType[question.questionType] =
          (byType[question.questionType] ?? 0) + 1;
    }

    final vocab = context.read<VocabProvider>();
    final Unit? unit = vocab.getUnit(session.unitId);
    final missedQuestionIds = session.answers
        .where((a) => !a.isCorrect)
        .map((a) => a.questionId)
        .toSet();
    final missedVocabIds = session.questions
        .where((q) => missedQuestionIds.contains(q.id))
        .map((q) => q.vocabularyItemId)
        .toSet();
    final missedItems = <String>[];
    if (unit != null) {
      final itemsById = {
        for (final item in unit.vocabularyItems) item.id: item,
      };
      for (final id in missedVocabIds) {
        final item = itemsById[id];
        if (item != null) {
          missedItems
              .add('${item.germanWord} – ${item.englishTranslation}');
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: ScoreDisplayWidget(
                  score: score,
                  isNewBest: isNewBest,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                rating,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, size: 18),
                  const SizedBox(width: 4),
                  Text('Time: $durationText'),
                  const SizedBox(width: 16),
                  const Icon(Icons.calendar_today, size: 18),
                  const SizedBox(width: 4),
                  Text(formatDate(session.startTime)),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Correct by question type',
                style:
                    Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...QuizQuestionType.values.map(
                (type) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(type.name),
                      Text('${byType[type] ?? 0}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (missedItems.isNotEmpty) ...[
                Text(
                  'Most missed words',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...missedItems.map(
                  (w) => Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2),
                    child: Text('• $w'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: ListView(
                  children: [
                    ExpansionTile(
                      title: const Text('Review answers'),
                      children: session.questions.map((q) {
                        final matchingAnswers = session.answers
                            .where(
                              (a) => a.questionId == q.id,
                            )
                            .toList();
                        final userAnswer = matchingAnswers.isNotEmpty
                            ? matchingAnswers.first.userAnswer
                            : null;
                        final isCorrect = matchingAnswers.isNotEmpty
                            ? matchingAnswers.first.isCorrect
                            : null;
                        return ListTile(
                          title: Text(q.germanWord),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Correct: ${q.correctAnswer}',
                              ),
                              Text(
                                'Your answer: ${userAnswer ?? '-'}',
                              ),
                            ],
                          ),
                          trailing: Icon(
                            isCorrect == true
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: isCorrect == true
                                ? Colors.green
                                : Colors.red,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () {
                  final vocab =
                      context.read<VocabProvider>();
                  final unit = vocab.getUnit(session.unitId);
                  if (unit != null) {
                    Navigator.of(context).pushNamed(
                      '/quiz',
                      arguments: unit,
                    );
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context)
                    .popUntil((route) => route.isFirst),
                child: const Text('Return to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

