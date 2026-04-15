import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/unit.dart';
import '../models/word.dart';
import '../providers/vocab_provider.dart';

class AddEditUnitScreen extends StatefulWidget {
  const AddEditUnitScreen({super.key, this.unit});

  final Unit? unit;

  @override
  State<AddEditUnitScreen> createState() => _AddEditUnitScreenState();
}

class _AddEditUnitScreenState extends State<AddEditUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _timeLimitController;
  final List<_WordPairController> _wordPairs = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.unit?.name ?? '');
    _timeLimitController = TextEditingController(
      text: (widget.unit?.timeLimitSeconds ?? 600).toString(),
    );
    if (widget.unit != null && widget.unit!.words.isNotEmpty) {
      for (final w in widget.unit!.words) {
        _wordPairs.add(_WordPairController(
          TextEditingController(text: w.native),
          TextEditingController(text: w.target),
        ));
      }
    } else {
      _addWordPair();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timeLimitController.dispose();
    for (final pair in _wordPairs) {
      pair.native.dispose();
      pair.target.dispose();
    }
    super.dispose();
  }

  void _addWordPair() {
    setState(() {
      _wordPairs.add(_WordPairController(
        TextEditingController(),
        TextEditingController(),
      ));
    });
  }

  void _removeWordPair(int index) {
    if (_wordPairs.length <= 1) return;
    setState(() {
      _wordPairs[index].native.dispose();
      _wordPairs[index].target.dispose();
      _wordPairs.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final words = <Word>[];
    for (final pair in _wordPairs) {
      final n = pair.native.text.trim();
      final t = pair.target.text.trim();
      if (n.isNotEmpty && t.isNotEmpty) {
        words.add(Word(native: n, target: t));
      }
    }

    if (words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one word pair')),
      );
      return;
    }

    final timeLimitSeconds = int.tryParse(_timeLimitController.text) ?? 600;

    final vocab = context.read<VocabProvider>();
    final unit = Unit(
      id: widget.unit?.id ?? '',
      name: _nameController.text.trim(),
      order: widget.unit?.order ?? 0,
      words: words,
      isCustom: true,
      timeLimitSeconds: timeLimitSeconds,
    );

    if (widget.unit != null && widget.unit!.id.isNotEmpty) {
      await vocab.updateUnit(unit);
    } else {
      await vocab.addUnit(unit);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _importUnits() async {
    final textController = TextEditingController();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Lessons'),
        content: SingleChildScrollView(
          child: TextField(
            controller: textController,
            minLines: 5,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Paste JSON data here',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final jsonData = textController.text.trim();

              if (jsonData.isEmpty) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please paste JSON data')),
                );
                return;
              }

              final vocab = context.read<VocabProvider>();
              try {
                final success = await vocab.importUnits(jsonData);
                if (!context.mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lessons imported successfully')),
                  );
                  if (mounted) Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to import lessons')),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Import error: $e')),
                );
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.unit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Unit' : 'Add Unit'),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.upload),
              tooltip: 'Import lessons',
              onPressed: _importUnits,
            ),
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
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter a name';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _timeLimitController,
              decoration: const InputDecoration(
                labelText: 'Time limit (seconds)',
                border: OutlineInputBorder(),
                helperText: 'e.g., 600 for 10 minutes',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter time limit';
                final seconds = int.tryParse(v);
                if (seconds == null || seconds < 30) {
                  return 'Minimum 30 seconds';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Words',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: _addWordPair,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(_wordPairs.length, (i) {
              return _WordPairRow(
                nativeController: _wordPairs[i].native,
                targetController: _wordPairs[i].target,
                onRemove: () => _removeWordPair(i),
                canRemove: _wordPairs.length > 1,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _WordPairController {
  final TextEditingController native;
  final TextEditingController target;
  _WordPairController(this.native, this.target);
}

class _WordPairRow extends StatelessWidget {
  const _WordPairRow({
    required this.nativeController,
    required this.targetController,
    required this.onRemove,
    required this.canRemove,
  });

  final TextEditingController nativeController;
  final TextEditingController targetController;
  final VoidCallback onRemove;
  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: nativeController,
              decoration: const InputDecoration(
                labelText: 'Native',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: targetController,
              decoration: const InputDecoration(
                labelText: 'Target',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                return null;
              },
            ),
          ),
          if (canRemove)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline),
              color: Theme.of(context).colorScheme.error,
            ),
        ],
      ),
    );
  }
}
