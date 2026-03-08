import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Repository for high-level statistics persisted in a dedicated Hive box.
///
/// This repository stores a single JSON blob containing aggregated stats
/// (overall scores, per-unit stats, streaks, etc.). Detailed quiz sessions
/// are handled by a separate session repository.
class StatsRepository {
  static const String _statsBoxName = 'stats';
  static const String _statsKey = 'global_stats';

  Box<String>? _statsBox;

  Future<Box<String>> _getBox() async {
    if (_statsBox != null) return _statsBox!;
    _statsBox = await Hive.openBox<String>(_statsBoxName);
    return _statsBox!;
  }

  /// Load the stats map from Hive. Returns an empty map if nothing is stored.
  Future<Map<String, dynamic>> loadStats() async {
    final box = await _getBox();
    final jsonString = box.get(_statsKey);
    if (jsonString == null) return {};
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  /// Persist the given stats map to Hive.
  Future<void> saveStats(Map<String, dynamic> stats) async {
    final box = await _getBox();
    await box.put(_statsKey, json.encode(stats));
  }
}

