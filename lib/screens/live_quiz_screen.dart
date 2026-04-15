import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/live_game.dart';
import '../models/unit.dart';
import '../repositories/live_game_repository.dart';
import '../utils/answer_validator.dart';
import 'live_results_screen.dart';

class LiveQuizScreen extends StatefulWidget {
  final String sessionId;

  const LiveQuizScreen({super.key, required this.sessionId});

  @override
  State<LiveQuizScreen> createState() => _LiveQuizScreenState();
}

class _LiveQuizScreenState extends State<LiveQuizScreen> {
  final LiveGameRepository _repo = LiveGameRepository();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  StreamSubscription<LiveGameSession>? _sub;
  Timer? _ticker;

  LiveGameSession? _session;
  int _remaining = 0;
  int _index = 0;
  List<int> _order = const [];
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _sub = _repo.watchSession(widget.sessionId).listen((s) {
      setState(() => _session = s);
      _ensureOrder(s.unitSnapshot, s.shuffleSeed);
      _syncRemaining();
      _ticker ??=
          Timer.periodic(const Duration(seconds: 1), (_) => _syncRemaining());

      if (s.status == LiveGameStatus.finished && !_done) {
        _finish();
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _sub?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _ensureOrder(Unit unit, int seed) {
    if (_order.isNotEmpty) return;
    final indices = List<int>.generate(unit.words.length, (i) => i);
    final r = Random(seed);
    indices.shuffle(r);
    _order = indices;
  }

  void _syncRemaining() {
    final endsAt = _session?.endsAt;
    if (endsAt == null) return;
    final seconds = endsAt.difference(DateTime.now()).inSeconds;
    final clipped = seconds < 0 ? 0 : seconds;
    if (clipped != _remaining) setState(() => _remaining = clipped);
    if (clipped == 0 && !_done) {
      _finish();
    }
  }

  Future<void> _submit() async {
    final session = _session;
    if (session == null || session.status != LiveGameStatus.live) return;
    if (_done) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final unit = session.unitSnapshot;
    if (_index >= _order.length) return;
    final wordIndex = _order[_index];
    final word = unit.words[wordIndex];
    final expected = word.target;
    final correct = validateAnswer(text, expected);

    await _repo.submitAttempt(session: session, wordIndex: wordIndex, correct: correct);

    _controller.clear();
    if (!mounted) return;
    setState(() => _index = _index + 1);
    if (_index >= _order.length) {
      _finish();
    }
  }

  void _finish() {
    if (_done) return;
    setState(() => _done = true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LiveResultsScreen(sessionId: widget.sessionId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live game'),
      ),
      body: session == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.unitSnapshot.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Chip(label: Text('${_remaining}s')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (session.status != LiveGameStatus.live)
                    Text(
                      session.status == LiveGameStatus.lobby
                          ? 'Waiting for host to start…'
                          : 'Game finished.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    )
                  else ...[
                    Expanded(
                      child: Center(
                        child: _buildPrompt(session.unitSnapshot),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        hintText: 'Type your answer…',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submit,
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildPrompt(Unit unit) {
    if (_order.isEmpty || _index >= _order.length) {
      return Text(
        'Done',
        style: Theme.of(context).textTheme.headlineMedium,
      );
    }
    final word = unit.words[_order[_index]];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Translate to German',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          word.native,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          '${_index + 1}/${_order.length}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

