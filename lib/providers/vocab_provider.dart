import 'package:flutter/foundation.dart';

import '../models/unit.dart';
import '../models/vocabulary_item.dart';
import '../repositories/vocab_repository.dart';

/// Provider responsible for managing vocabulary units and their items.
class VocabProvider extends ChangeNotifier {
  final VocabRepository _repository = VocabRepository();

  List<Unit> _units = [];
  bool _isLoading = false;

  List<Unit> get units => List.unmodifiable(_units);
  bool get isLoading => _isLoading;

  /// Load units from Hive on startup.
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    _units = await _repository.loadUnits();
    _isLoading = false;
    notifyListeners();
  }

  /// Persist current units to Hive.
  Future<void> saveToHive() async {
    await _repository.saveUnits(_units);
  }

  /// Create a new unit.
  Future<void> addUnit(Unit unit) async {
    _units = [..._units, unit];
    await saveToHive();
    notifyListeners();
  }

  /// Edit an existing unit (by id).
  Future<void> updateUnit(Unit updated) async {
    _units = _units
        .map((u) => u.id == updated.id ? updated : u)
        .toList(growable: false);
    await saveToHive();
    notifyListeners();
  }

  /// Delete a unit and all its vocabulary items.
  Future<void> deleteUnit(String unitId) async {
    _units = _units.where((u) => u.id != unitId).toList(growable: false);
    await _repository.deleteUnit(unitId);
    notifyListeners();
  }

  /// Add a vocabulary item to the given unit.
  Future<void> addVocabularyItem(String unitId, VocabularyItem item) async {
    final unit = getUnit(unitId);
    if (unit == null) return;
    final updated = unit.copyWith(
      vocabularyItems: [...unit.vocabularyItems, item],
    );
    await updateUnit(updated);
  }

  /// Update an existing vocabulary item inside a unit.
  Future<void> updateVocabularyItem(
    String unitId,
    VocabularyItem item,
  ) async {
    final unit = getUnit(unitId);
    if (unit == null) return;
    final updatedItems = unit.vocabularyItems
        .map((v) => v.id == item.id ? item : v)
        .toList(growable: false);
    final updatedUnit = unit.copyWith(vocabularyItems: updatedItems);
    await updateUnit(updatedUnit);
  }

  /// Delete a vocabulary item from a unit.
  Future<void> deleteVocabularyItem(String unitId, String itemId) async {
    final unit = getUnit(unitId);
    if (unit == null) return;
    final updatedItems = unit.vocabularyItems
        .where((v) => v.id != itemId)
        .toList(growable: false);
    final updatedUnit = unit.copyWith(vocabularyItems: updatedItems);
    await updateUnit(updatedUnit);
  }

  /// Fetch a single unit by id.
  Unit? getUnit(String unitId) {
    try {
      return _units.firstWhere((u) => u.id == unitId);
    } catch (_) {
      return null;
    }
  }

  /// Get all units.
  List<Unit> getAllUnits() => List.unmodifiable(_units);

  /// Get all vocabulary items within a unit.
  List<VocabularyItem> getUnitItems(String unitId) {
    final unit = getUnit(unitId);
    return unit?.vocabularyItems ?? const [];
  }
}

