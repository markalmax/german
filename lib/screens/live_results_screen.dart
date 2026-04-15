import 'package:flutter/material.dart';

import '../models/live_game.dart';
import '../repositories/live_game_repository.dart';

class LiveResultsScreen extends StatelessWidget {
  final String sessionId;

  const LiveResultsScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final repo = LiveGameRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: StreamBuilder<List<LiveGamePlayer>>(
        stream: repo.watchLeaderboard(sessionId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final players = snap.data ?? const <LiveGamePlayer>[];
          if (players.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No players found.'),
              ),
            );
          }
          return ListView.separated(
            itemCount: players.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = players[i];
              return ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(p.displayName.isEmpty ? 'Player' : p.displayName),
                subtitle: Text('${p.correctCount}/${p.totalAttempts}'),
                trailing: Text(
                  '${p.score}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

