import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/unit.dart';
import '../providers/vocab_provider.dart';
import '../repositories/live_game_repository.dart';
import 'host_live_lobby_screen.dart';

class HostLiveGameScreen extends StatefulWidget {
  const HostLiveGameScreen({super.key});

  @override
  State<HostLiveGameScreen> createState() => _HostLiveGameScreenState();
}

class _HostLiveGameScreenState extends State<HostLiveGameScreen> {
  final LiveGameRepository _repo = LiveGameRepository();
  bool _creating = false;

  Future<void> _host(Unit unit) async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      final session = await _repo.createLobby(unit: unit);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HostLiveLobbyScreen(sessionId: session.id),
        ),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Host a live game')),
      body: Consumer<VocabProvider>(
        builder: (context, vocab, _) {
          if (!vocab.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vocab.units.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Create at least one unit before hosting a live game.'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: vocab.units.length,
            itemBuilder: (context, index) {
              final unit = vocab.units[index];
              return ListTile(
                title: Text(unit.name),
                subtitle: Text('${unit.words.length} words • ${unit.timeLimitSeconds}s'),
                trailing: _creating ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator()) : const Icon(Icons.chevron_right),
                onTap: _creating ? null : () => _host(unit),
              );
            },
          );
        },
      ),
    );
  }
}

