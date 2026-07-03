import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../services/exercise_service.dart';
import '../../theme.dart';
import 'exercise_form_screen.dart';

class ExercisesListScreen extends StatefulWidget {
  const ExercisesListScreen({super.key});

  @override
  State<ExercisesListScreen> createState() => _ExercisesListScreenState();
}

class _ExercisesListScreenState extends State<ExercisesListScreen> {
  final _service = ExerciseService();
  late Future<List<Exercise>> _future;
  String? _category;

  final _categories = const {
    null: 'Todas',
    'cardio': 'Cardio',
    'pesas': 'Pesas',
    'funcional': 'Funcional',
    'flexibilidad': 'Flexibilidad',
    'tecnica': 'Tecnica',
  };

  @override
  void initState() {
    super.initState();
    _future = _service.list();
  }

  void _reload() => setState(() { _future = _service.list(category: _category); });

  IconData _iconFor(String category) {
    switch (category) {
      case 'cardio':
        return Icons.directions_run;
      case 'funcional':
        return Icons.accessibility_new;
      case 'flexibilidad':
        return Icons.self_improvement;
      case 'tecnica':
        return Icons.sports_gymnastics;
      default:
        return Icons.fitness_center;
    }
  }

  Future<void> _openForm({Exercise? exercise}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ExerciseFormScreen(exercise: exercise)),
    );
    if (changed == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banco de ejercicios')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _categories.entries.map((e) {
                final selected = _category == e.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(e.value),
                    selected: selected,
                    onSelected: (_) {
                      _category = e.key;
                      _reload();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Exercise>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final exercises = snap.data ?? [];
                if (exercises.isEmpty) return const Center(child: Text('Sin ejercicios'));
                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: exercises.length,
                    itemBuilder: (context, i) {
                      final ex = exercises[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _openForm(exercise: ex),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                                  child: Icon(_iconFor(ex.category), color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Expanded(child: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(5, (i) => Icon(
                                                Icons.circle,
                                                size: 7,
                                                color: i < ex.difficulty ? AppColors.primary : Colors.grey.shade300,
                                              )),
                                        ),
                                      ]),
                                      if (ex.muscleGroups.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(ex.muscleGroups.join(', '), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        ),
                                      if (ex.description != null && ex.description!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Text(
                                            ex.description!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
