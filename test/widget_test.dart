// Widget and utility tests for the Vocabulary Quiz app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:german/utils/answer_validator.dart';
import 'package:german/widgets/timer_display.dart';
import 'package:german/widgets/word_display.dart';

void main() {
  group('AnswerValidator', () {
    test('accepts exact match', () {
      expect(validateAnswer('hallo', 'hallo'), isTrue);
    });

    test('accepts match with different case', () {
      expect(validateAnswer('HALLO', 'hallo'), isTrue);
      expect(validateAnswer('hallo', 'HALLO'), isTrue);
    });

    test('accepts comma-separated alternatives', () {
      expect(validateAnswer('hi', 'hallo,hi'), isTrue);
      expect(validateAnswer('hallo', 'hallo,hi'), isTrue);
    });

    test('rejects wrong answer', () {
      expect(validateAnswer('hello', 'hallo'), isFalse);
    });

    test('rejects empty answer', () {
      expect(validateAnswer('', 'hallo'), isFalse);
      expect(validateAnswer('   ', 'hallo'), isFalse);
    });
  });

  group('WordDisplay', () {
    testWidgets('shows prompt and hint', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordDisplay(
              prompt: 'hello',
              hint: 'Translate to German',
            ),
          ),
        ),
      );

      expect(find.text('hello'), findsOneWidget);
      expect(find.text('Translate to German'), findsOneWidget);
    });
  });

  group('TimerDisplay', () {
    testWidgets('shows formatted time', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerDisplay(remainingSeconds: 125),
          ),
        ),
      );

      expect(find.text('02:05'), findsOneWidget);
    });
  });
}
