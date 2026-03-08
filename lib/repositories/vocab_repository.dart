import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/unit.dart';

class VocabRepository {
  static const String _unitsBoxName = 'units';
  static const String _predefinedAssetPath = 'assets/data/units.json';

  Box<String>? _unitsBox;

  Future<void> init() async {
    _unitsBox = await Hive.openBox<String>(_unitsBoxName);
  }

  Future<List<Unit>> loadPredefinedUnits() async {
    final jsonString = await rootBundle.loadString(_predefinedAssetPath);
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .asMap()
        .entries
        .map((e) => Unit.fromMap(
              e.value as Map<String, dynamic>,
              idOverride: 'predefined_${e.key}',
            ))
        .toList();
  }

  Future<List<Unit>> loadCustomUnits() async {
    if (_unitsBox == null) return [];
    final units = <Unit>[];
    for (final key in _unitsBox!.keys) {
      final jsonString = _unitsBox!.get(key);
      if (jsonString != null) {
        final map = json.decode(jsonString) as Map<String, dynamic>;
        map['isCustom'] = true;
        final unit = Unit.fromMap(map, idOverride: key as String);
        units.add(unit);
      }
    }
    return units..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<List<Unit>> getAllUnits() async {
    final predefined = await loadPredefinedUnits();
    final custom = await loadCustomUnits();
    final maxOrder = predefined.isEmpty ? 0 : predefined.map((u) => u.order).reduce((a, b) => a > b ? a : b);
    for (var i = 0; i < custom.length; i++) {
      custom[i] = Unit(
        id: custom[i].id,
        name: custom[i].name,
        order: maxOrder + 1 + i,
        words: custom[i].words,
        isCustom: true,
      );
    }
    return [...predefined, ...custom]..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<void> saveCustomUnit(Unit unit) async {
    if (_unitsBox == null) return;
    final id = unit.id.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : unit.id;
    final unitToSave = Unit(
      id: id,
      name: unit.name,
      order: unit.order,
      words: unit.words,
      isCustom: true,
    );
    await _unitsBox!.put(id, json.encode(unitToSave.toMap()));
  }

  Future<void> deleteCustomUnit(String unitId) async {
    await _unitsBox?.delete(unitId);
  }

  Future<void> updateCustomUnit(Unit unit) async {
    if (unit.id.isEmpty) return;
    await saveCustomUnit(unit);
  }
}
