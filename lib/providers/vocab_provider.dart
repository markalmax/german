import 'package:flutter/foundation.dart';

import '../models/unit.dart';
import '../repositories/vocab_repository.dart';

class VocabProvider extends ChangeNotifier {
  final VocabRepository _repo = VocabRepository();
  List<Unit> _units = [];
  bool _loaded = false;

  List<Unit> get units => List.unmodifiable(_units);
  bool get isLoaded => _loaded;

  Future<void> init() async {
    await _repo.init();
  }

  Future<void> loadUnits() async {
    await init();
    _units = await _repo.getAllUnits();
    _loaded = true;
    notifyListeners();
  }

  Future<void> addUnit(Unit unit) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final unitToSave = unit.copyWith(
      id: id,
      order: _units.isEmpty ? 0 : _units.map((u) => u.order).reduce((a, b) => a > b ? a : b) + 1,
      isCustom: true,
    );
    await _repo.saveCustomUnit(unitToSave);
    await loadUnits();
  }

  Future<void> updateUnit(Unit unit) async {
    if (!unit.isCustom) return;
    await _repo.updateCustomUnit(unit);
    await loadUnits();
  }

  Future<void> deleteUnit(String unitId) async {
    await _repo.deleteCustomUnit(unitId);
    await loadUnits();
  }

  Unit? getUnitById(String id) {
    try {
      return _units.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<String> exportUnits({bool onlyCustom = true}) async {
    return await _repo.exportUnits(onlyCustom: onlyCustom);
  }

  Future<String> exportUnit(Unit unit) async {
    return await _repo.exportUnit(unit);
  }

  Future<bool> importUnits(String jsonString) async {
    final success = await _repo.importUnits(jsonString);
    if (success) {
      await loadUnits();
    }
    return success;
  }
}
