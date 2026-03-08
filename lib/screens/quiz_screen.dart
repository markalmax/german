import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/quiz_question.dart';
import '../models/unit.dart';
import '../providers/quiz_provider.dart';
import '../providers/stats_provider.dart';
import '../utils/constants.dart';
import '../widgets/quiz_question_widget.dart';

class QuizScreen extends StatefulWidget {
  final Unit unit;

  const QuizScreen({super.key, required this.unit});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _completionHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().startQuiz(widget.unit);
    });
  }

  Future<void> _handleQuit() async {
    final shouldQuit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit quiz?'),
        content: const Text(
          'Your progress in this quiz will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Quit'),
          ),
        ],
      ),
    );

    if (shouldQuit == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleAnswer(
    QuizProvider quiz,
    QuizQuestion question,
    String answer,
  ) {
    quiz.submitAnswer(question.id, answer);
  }

  void _goToNextQuestion(QuizProvider quiz) {
    quiz.nextQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<QuizProvider, StatsProvider>(
      builder: (context, quiz, stats, _) {
        final session = quiz.currentSession;

        if (!quiz.isQuizActive &&
            session != null &&
            session.isCompleted &&
            !_completionHandled) {
          _completionHandled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final previous = stats.unitStats[session.unitId];
            final isNewBest =
                previous == null || session.score > previous.averageScore;
            await stats.recordQuizSession(session);
            if (!mounted) return;
            Navigator.of(context).pushReplacementNamed(
              '/results',
              arguments: {
                'session': session,
                'isNewBest': isNewBest,
              },
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final question = quiz.getCurrentQuestion();
        final currentIndex = quiz.getCurrentQuestionIndex();
        final total = quiz.totalQuestions;

        if (session == null || question == null || total == 0) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final answered = session.answers
            .any((a) => a.questionId == question.id);
        final existingAnswerEntry = session.answers.where(
          (a) => a.questionId == question.id,
        );
        final existingAnswer =
            existingAnswerEntry.isNotEmpty ? existingAnswerEntry.first.userAnswer : null;

        final progress = (currentIndex + 1) / total;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.unit.name),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: _handleQuit,
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question ${currentIndex + 1} of $total',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium,
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(value: progress),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${quiz.remainingSeconds}s',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium,
                          ),
                          SizedBox(
                            width: 80,
                            child: LinearProgressIndicator(
                              value: quiz.remainingSeconds /
                                  QUESTION_TIME_LIMIT_SECONDS,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text(
                        question.questionType.name
                            .replaceAll('translateTo', 'Translate to ')
                            .replaceAll('multipleChoice', 'Multiple choice')
                            .replaceAll('trueFalse', 'True / False')
                            .replaceAll('fillBlank', 'Fill in the blank'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: QuizQuestionWidget(
                      question: question,
                      onAnswer: (answer) =>
                          _handleAnswer(quiz, question, answer),
                      answered: answered,
                      userAnswer: existingAnswer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (!answered)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                _goToNextQuestion(quiz),
                            child: const Text('Skip'),
                          ),
                        ),
                      if (!answered) const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: answered
                              ? () => _goToNextQuestion(quiz)
                              : () {
                                  // For free text questions, we rely on
                                  // the internal TextField submission.
                                  if (question.options.isEmpty) {
                                    return;
                                  }
                                },
                          child: Text(
                            answered ? 'Next' : 'Submit',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

