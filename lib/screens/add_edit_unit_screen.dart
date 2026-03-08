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
  final List<_WordPairController> _wordPairs = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.unit?.name ?? '');
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

    final vocab = context.read<VocabProvider>();
    final unit = Unit(
      id: widget.unit?.id ?? '',
      name: _nameController.text.trim(),
      order: widget.unit?.order ?? 0,
      words: words,
      isCustom: true,
    );

    if (widget.unit != null && widget.unit!.id.isNotEmpty) {
      await vocab.updateUnit(unit);
    } else {
      await vocab.addUnit(unit);
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
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter a name';
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
