import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/unit.dart';

/// Repository responsible for persisting vocabulary units in Hive.
class VocabRepository {
  static const String _unitsBoxName = 'units';

  Box<String>? _unitsBox;

  Future<Box<String>> _getBox() async {
    if (_unitsBox != null) return _unitsBox!;
    _unitsBox = await Hive.openBox<String>(_unitsBoxName);
    return _unitsBox!;
  }

  /// Load all units from Hive.
  Future<List<Unit>> loadUnits() async {
    final box = await _getBox();
    final units = <Unit>[];
    for (final key in box.keys) {
      final jsonString = box.get(key);
      if (jsonString == null) continue;
      final map = json.decode(jsonString) as Map<String, dynamic>;
      units.add(Unit.fromMap(map));
    }
    units.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return units;
  }

  /// Persist the given list of units to Hive, replacing previous contents.
  Future<void> saveUnits(List<Unit> units) async {
    final box = await _getBox();
    await box.clear();
    for (final unit in units) {
      await box.put(unit.id, json.encode(unit.toMap()));
    }
  }

  /// Fetch a single unit by its id.
  Future<Unit?> getUnit(String unitId) async {
    final box = await _getBox();
    final jsonString = box.get(unitId);
    if (jsonString == null) return null;
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return Unit.fromMap(map);
  }

  /// Delete a unit by its id.
  Future<void> deleteUnit(String unitId) async {
    final box = await _getBox();
    await box.delete(unitId);
  }
}

