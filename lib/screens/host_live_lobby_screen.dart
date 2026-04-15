import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/live_game.dart';
import '../repositories/live_game_repository.dart';
import 'host_live_dashboard_screen.dart';

class HostLiveLobbyScreen extends StatefulWidget {
  final String sessionId;

  const HostLiveLobbyScreen({super.key, required this.sessionId});

  @override
  State<HostLiveLobbyScreen> createState() => _HostLiveLobbyScreenState();
}

class _HostLiveLobbyScreenState extends State<HostLiveLobbyScreen> {
  final LiveGameRepository _repo = LiveGameRepository();
  StreamSubscription<LiveGameSession>? _sub;
  LiveGameSession? _session;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _sub = _repo.watchSession(widget.sessionId).listen((s) {
      setState(() => _session = s);
      if (s.status == LiveGameStatus.live && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HostLiveDashboardScreen(sessionId: widget.sessionId),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    final session = _session;
    if (session == null || _starting) return;
    setState(() => _starting = true);
    try {
      await _repo.startSession(
        sessionId: session.id,
        durationSeconds: session.durationSeconds,
      );
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    return Scaffold(
      appBar: AppBar(title: const Text('Live game lobby')),
      body: session == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.unitSnapshot.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${session.unitSnapshot.words.length} words • ${session.durationSeconds}s',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Room code',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    session.roomCode,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: session.roomCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied room code.')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy code'),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _starting ? null : _start,
                      child: _starting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Start now'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

