import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/unit.dart';
import '../providers/quiz_provider.dart';
import '../providers/stats_provider.dart';
import '../widgets/timer_display.dart';
import '../widgets/word_display.dart';

class QuizScreen extends StatefulWidget {
  final Unit unit;

  const QuizScreen({super.key, required this.unit});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().startQuiz(widget.unit);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final quiz = context.read<QuizProvider>();
    final text = _controller.text;
    if (text.isEmpty) return;

    quiz.submitAnswer(text);
    _controller.clear();

    // Haptic feedback
    if (quiz.state.lastCorrect == true) {
      HapticFeedback.lightImpact();
    } else if (quiz.state.lastCorrect == false) {
      HapticFeedback.heavyImpact();
    }
  }

  void _skip() {
    context.read<QuizProvider>().skipWord();
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quiz, _) {
        if (!quiz.state.isActive && quiz.state.totalAttempts > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final session = quiz.finishQuiz();
            if (session != null && context.mounted) {
              final stats = context.read<StatsProvider>();
              final existing = stats.getStatsForUnit(session.unitId);
              final isNewBest = existing == null ||
                  session.correctCount > existing.bestScore;
              stats.saveSession(session);
              Navigator.of(context).pushReplacementNamed(
                '/results',
                arguments: {
                  'session': session,
                  'isNewBest': isNewBest,
                },
              );
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final state = quiz.state;
        final word = state.currentWord;
        final prompt = word != null
            ? (state.direction == QuizDirection.nativeToTarget
                ? word.native
                : word.target)
            : '';
        final hint = word != null
            ? (state.direction == QuizDirection.nativeToTarget
                ? 'Translate to German'
                : 'Translate to English')
            : '';

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.unit.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: _skip,
                tooltip: 'Skip',
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TimerDisplay(remainingSeconds: state.remainingSeconds),
                  const SizedBox(height: 48),
                  Expanded(
                    child: Center(
                      child: WordDisplay(prompt: prompt, hint: hint),
                    ),
                  ),
                  if (state.lastCorrect != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Icon(
                        state.lastCorrect! ? Icons.check_circle : Icons.cancel,
                        color: state.lastCorrect!
                            ? Colors.green
                            : Colors.red,
                        size: 32,
                      ),
                    ),
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: 'Type your answer...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _submit,
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
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
