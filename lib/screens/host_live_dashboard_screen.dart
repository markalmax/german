import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/live_game.dart';
import '../repositories/live_game_repository.dart';

class HostLiveDashboardScreen extends StatefulWidget {
  final String sessionId;

  const HostLiveDashboardScreen({super.key, required this.sessionId});

  @override
  State<HostLiveDashboardScreen> createState() => _HostLiveDashboardScreenState();
}

class _HostLiveDashboardScreenState extends State<HostLiveDashboardScreen> {
  final LiveGameRepository _repo = LiveGameRepository();
  StreamSubscription<LiveGameSession>? _sub;
  LiveGameSession? _session;
  Timer? _ticker;
  int _remaining = 0;

  @override
  void initState() {
    super.initState();
    _sub = _repo.watchSession(widget.sessionId).listen((s) {
      setState(() => _session = s);
      _syncRemaining();
      _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => _syncRemaining());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  void _syncRemaining() {
    final endsAt = _session?.endsAt;
    if (endsAt == null) return;
    final seconds = endsAt.difference(DateTime.now()).inSeconds;
    final clipped = seconds < 0 ? 0 : seconds;
    if (clipped != _remaining) setState(() => _remaining = clipped);
    if (clipped == 0 && _session?.status == LiveGameStatus.live) {
      // Best-effort: host flips session to finished.
      _repo.finishSession(widget.sessionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host dashboard'),
      ),
      body: session == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.unitSnapshot.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Chip(
                        label: Text('${_remaining}s'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('live_sessions')
                        .doc(session.id)
                        .snapshots(),
                    builder: (context, snap) {
                      final data = snap.data?.data();
                      final wrongCountsRaw = data?['wrongCounts'];
                      final wrongCounts = wrongCountsRaw is Map
                          ? wrongCountsRaw.map(
                              (k, v) => MapEntry(k.toString(), (v as num).toInt()),
                            )
                          : <String, int>{};

                      if (wrongCounts.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final entries = wrongCounts.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));
                      final top = entries.first;

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.insights_outlined),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Most missed: ${top.key}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Chip(label: Text('${top.value}×')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<LiveGamePlayer>>(
                    stream: _repo.watchLeaderboard(session.id),
                    builder: (context, snap) {
                      final players = snap.data ?? const <LiveGamePlayer>[];
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (players.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('No players yet.'),
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
                ),
              ],
            ),
    );
  }
}

