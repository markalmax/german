import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/unit.dart';
import '../providers/vocab_provider.dart';
import '../widgets/unit_card.dart';
import 'add_edit_unit_screen.dart';
import 'quiz_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'unit_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final vocab = context.read<VocabProvider>();
    if (!vocab.isLoaded) {
      await vocab.loadUnits();
    }
  }

  void _navigateToQuiz(Unit unit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizScreen(unit: unit),
      ),
    );
  }

  void _navigateToUnitDetail(Unit unit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UnitDetailScreen(unit: unit),
      ),
    );
  }

  void _navigateToAddUnit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditUnitScreen(),
      ),
    ).then((_) => _loadData());
  }

  void _navigateToStats() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const StatsScreen(),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _navigateToHostLiveGame() {
    Navigator.of(context).pushNamed('/host-live');
  }

  void _navigateToJoinLiveGame() {
    Navigator.of(context).pushNamed('/join-live');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _navigateToStats,
            tooltip: 'Stats',
          ),
        ],
      ),
      body: Consumer<VocabProvider>(
        builder: (context, vocab, _) {
          if (!vocab.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredUnits = _searchController.text.isEmpty
              ? vocab.units
              : vocab.units
                  .where((unit) => unit.name
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase()))
                  .toList();

          if (vocab.units.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No units yet',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first unit to start learning!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _navigateToAddUnit,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Unit'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _navigateToHostLiveGame,
                          icon: const Icon(Icons.cast),
                          label: const Text('Host live'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _navigateToJoinLiveGame,
                          icon: const Icon(Icons.login),
                          label: const Text('Join'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search units...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                Expanded(
                  child: filteredUnits.isEmpty
                      ? Center(
                          child: Text(
                            'No units found',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filteredUnits.length,
                          itemBuilder: (context, index) {
                            final unit = filteredUnits[index];
                            return UnitCard(
                              unit: unit,
                              onStartQuiz: () => _navigateToQuiz(unit),
                              onTap: () => _navigateToUnitDetail(unit),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddUnit,
        tooltip: 'Add Unit',
        child: const Icon(Icons.add),
      ),
    );
  }
}
