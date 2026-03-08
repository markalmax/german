import 'package:flutter/material.dart';

import '../models/quiz_question.dart';

class QuizQuestionWidget extends StatelessWidget {
  final QuizQuestion question;
  final Function(String) onAnswer;
  final bool answered;
  final String? userAnswer;

  const QuizQuestionWidget({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.answered,
    this.userAnswer,
  });

  @override
  Widget build(BuildContext context) {
    switch (question.questionType) {
      case QuizQuestionType.multipleChoice:
      case QuizQuestionType.fillBlank:
        return _buildMultipleChoice(context);
      case QuizQuestionType.trueFalse:
        return _buildTrueFalse(context);
      case QuizQuestionType.translateToEnglish:
      case QuizQuestionType.translateToGerman:
        return _buildFreeText(context);
    }
  }

  Widget _buildPrompt(BuildContext context, String title, String subtitle) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoice(BuildContext context) {
    final isFillBlank =
        question.questionType == QuizQuestionType.fillBlank;
    final title = isFillBlank
        ? 'Fill in the blank'
        : 'Choose the correct translation';
    final subtitle =
        isFillBlank ? question.germanWord : question.germanWord;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPrompt(context, title, subtitle),
        const SizedBox(height: 16),
        ...question.options.map(
          (opt) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FilledButton.tonal(
              onPressed: answered ? null : () => onAnswer(opt),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(opt),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrueFalse(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPrompt(
          context,
          'True or false?',
          '${question.germanWord} = ${question.englishTranslation}',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: answered ? null : () => onAnswer('True'),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.primaryContainer,
                ),
                child: const Text('True'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: answered ? null : () => onAnswer('False'),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.errorContainer,
                ),
                child: const Text('False'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFreeText(BuildContext context) {
    final isToEnglish =
        question.questionType == QuizQuestionType.translateToEnglish;
    final prompt = isToEnglish
        ? 'Translate to English'
        : 'Translate to German';

    return _FreeTextQuestionField(
      title: prompt,
      promptText:
          isToEnglish ? question.germanWord : question.englishTranslation,
      answered: answered,
      initialAnswer: userAnswer,
      onAnswer: onAnswer,
      buildPrompt: (title, subtitle) =>
          _buildPrompt(context, title, subtitle),
    );
  }
}

class _FreeTextQuestionField extends StatefulWidget {
  const _FreeTextQuestionField({
    required this.title,
    required this.promptText,
    required this.answered,
    required this.initialAnswer,
    required this.onAnswer,
    required this.buildPrompt,
  });

  final String title;
  final String promptText;
  final bool answered;
  final String? initialAnswer;
  final Function(String) onAnswer;
  final Widget Function(String title, String subtitle) buildPrompt;

  @override
  State<_FreeTextQuestionField> createState() =>
      _FreeTextQuestionFieldState();
}

class _FreeTextQuestionFieldState extends State<_FreeTextQuestionField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.initialAnswer ?? '');
  }

  @override
  void didUpdateWidget(covariant _FreeTextQuestionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialAnswer != widget.initialAnswer &&
        widget.initialAnswer != _controller.text) {
      _controller.text = widget.initialAnswer ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widget.buildPrompt(widget.title, widget.promptText),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          enabled: !widget.answered,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: widget.answered ? null : widget.onAnswer,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Type your answer...',
          ),
        ),
      ],
    );
  }
}


