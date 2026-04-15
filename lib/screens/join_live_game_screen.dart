import 'package:flutter/material.dart';

import '../repositories/live_game_repository.dart';
import 'live_quiz_screen.dart';

class JoinLiveGameScreen extends StatefulWidget {
  const JoinLiveGameScreen({super.key});

  @override
  State<JoinLiveGameScreen> createState() => _JoinLiveGameScreenState();
}

class _JoinLiveGameScreenState extends State<JoinLiveGameScreen> {
  final LiveGameRepository _repo = LiveGameRepository();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();

  bool _joining = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeController.text.trim().toUpperCase();
    final name = _nameController.text.trim();
    if (code.isEmpty || name.isEmpty) {
      setState(() => _error = 'Enter a room code and your name.');
      return;
    }
    setState(() {
      _error = null;
      _joining = true;
    });
    try {
      final session = await _repo.findByRoomCode(code);
      if (session == null) {
        setState(() => _error = 'Room not found.');
        return;
      }
      await _repo.joinSession(sessionId: session.id, displayName: name);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LiveQuizScreen(sessionId: session.id),
        ),
      );
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join live game')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Room code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your name',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _joining ? null : _join,
                child: _joining
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Join'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

