import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/unit.dart';
import '../models/vocabulary_item.dart';
import '../providers/vocab_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class AddEditUnitScreen extends StatefulWidget {
  const AddEditUnitScreen({super.key, this.unit});

  final Unit? unit;

  @override
  State<AddEditUnitScreen> createState() => _AddEditUnitScreenState();
}

class _AddEditUnitScreenState extends State<AddEditUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final List<_VocabItemControllers> _items = [];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.unit?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.unit?.description ?? '');

    if (widget.unit != null &&
        widget.unit!.vocabularyItems.isNotEmpty) {
      for (final item in widget.unit!.vocabularyItems) {
        _items.add(
          _VocabItemControllers(
            id: item.id,
            german: TextEditingController(text: item.germanWord),
            english:
                TextEditingController(text: item.englishTranslation),
            exampleDe:
                TextEditingController(text: item.exampleSentence),
            exampleEn:
                TextEditingController(text: item.exampleTranslation),
            partOfSpeech:
                TextEditingController(text: item.partOfSpeech),
          ),
        );
      }
    } else {
      _addItem();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (final c in _items) {
      c.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    if (_items.length >= MAX_VOCABULARY_PER_UNIT) return;
    setState(() {
      _items.add(
        _VocabItemControllers(
          id: '',
          german: TextEditingController(),
          english: TextEditingController(),
          exampleDe: TextEditingController(),
          exampleEn: TextEditingController(),
          partOfSpeech: TextEditingController(),
        ),
      );
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final vocabProvider = context.read<VocabProvider>();

    final items = <VocabularyItem>[];
    for (final c in _items) {
      final german = c.german.text.trim();
      final english = c.english.text.trim();
      if (german.isEmpty || english.isEmpty) continue;
      items.add(
        VocabularyItem(
          id: c.id.isNotEmpty
              ? c.id
              : DateTime.now()
                  .microsecondsSinceEpoch
                  .toString(),
          germanWord: german,
          englishTranslation: english,
          exampleSentence: c.exampleDe.text.trim(),
          exampleTranslation: c.exampleEn.text.trim(),
          partOfSpeech: c.partOfSpeech.text.trim(),
        ),
      );
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Add at least one vocabulary item.'),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final existing = widget.unit;
    final unit = Unit(
      id: existing?.id ??
          now.microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      vocabularyItems: items,
      createdAt: existing?.createdAt ?? now,
      isCompleted: existing?.isCompleted ?? false,
      competencyLevel: existing?.competencyLevel ?? 0.0,
    );

    if (existing != null) {
      await vocabProvider.updateUnit(unit);
    } else {
      await vocabProvider.addUnit(unit);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.unit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Unit' : 'Add Unit'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Unit name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                LengthLimitingTextInputFormatter(80),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vocabulary items',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(_items.length, (index) {
              return _VocabularyItemForm(
                controllers: _items[index],
                onRemove: () => _removeItem(index),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _VocabItemControllers {
  _VocabItemControllers({
    required this.id,
    required this.german,
    required this.english,
    required this.exampleDe,
    required this.exampleEn,
    required this.partOfSpeech,
  });

  final String id;
  final TextEditingController german;
  final TextEditingController english;
  final TextEditingController exampleDe;
  final TextEditingController exampleEn;
  final TextEditingController partOfSpeech;

  void dispose() {
    german.dispose();
    english.dispose();
    exampleDe.dispose();
    exampleEn.dispose();
    partOfSpeech.dispose();
  }
}

class _VocabularyItemForm extends StatelessWidget {
  const _VocabularyItemForm({
    required this.controllers,
    required this.onRemove,
  });

  final _VocabItemControllers controllers;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controllers.german,
                    decoration: const InputDecoration(
                      labelText: 'German',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Required';
                      }
                      if (!isValidGermanWord(v)) {
                        return 'Invalid German word';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: controllers.english,
                    decoration: const InputDecoration(
                      labelText: 'English',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Required';
                      }
                      if (!isValidEnglishTranslation(v)) {
                        return 'Invalid English';
                      }
                      return null;
                    },
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controllers.partOfSpeech,
              decoration: const InputDecoration(
                labelText: 'Part of speech (e.g. noun, verb)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controllers.exampleDe,
              decoration: const InputDecoration(
                labelText: 'Example sentence (German)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controllers.exampleEn,
              decoration: const InputDecoration(
                labelText: 'Example translation (English)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

