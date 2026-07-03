import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../models/routine.dart';
import '../../services/exercise_service.dart';
import '../../services/routine_service.dart';

class RoutineEditScreen extends StatefulWidget {
  final int studentId;
  final Routine? routine;

  const RoutineEditScreen({super.key, required this.studentId, this.routine});

  @override
  State<RoutineEditScreen> createState() => _RoutineEditScreenState();
}

class _RoutineEditScreenState extends State<RoutineEditScreen> {
  final _service = RoutineService();
  final _exerciseService = ExerciseService();
  late final _nameCtrl = TextEditingController(text: widget.routine?.name ?? '');
  late List<RoutineExercise> _exercises;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _exercises = widget.routine?.exercises
            .map((e) => RoutineExercise(
                  id: e.id,
                  exercise: e.exercise,
                  sets: e.sets,
                  reps: e.reps,
                  weight: e.weight,
                  durationSeconds: e.durationSeconds,
                  restSeconds: e.restSeconds,
                  notes: e.notes,
                ))
            .toList() ??
        [];
  }

  Future<void> _addExercise() async {
    final exercises = await _exerciseService.list();
    if (!mounted) return;
    final selected = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        builder: (ctx, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Elegir ejercicio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: exercises.isEmpty
                    ? const Center(
                        child: Text('No hay ejercicios en el banco todavia.\nAgrega uno desde la seccion Ejercicios.',
                            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                        controller: scrollCtrl,
                        itemCount: exercises.length,
                        itemBuilder: (context, i) {
                          final ex = exercises[i];
                          return ListTile(
                            title: Text(ex.name),
                            subtitle: Text(ex.category),
                            onTap: () => Navigator.of(ctx).pop(ex),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) {
      setState(() => _exercises.add(RoutineExercise(exercise: selected, sets: 3, reps: 10)));
    }
  }

  void _removeExercise(int index) {
    setState(() => _exercises.removeAt(index));
  }

  Future<void> _editExercise(int index) async {
    final re = _exercises[index];
    final setsCtrl = TextEditingController(text: re.sets?.toString() ?? '');
    final repsCtrl = TextEditingController(text: re.reps?.toString() ?? '');
    final weightCtrl = TextEditingController(text: re.weight?.toString() ?? '');
    final durationCtrl = TextEditingController(text: re.durationSeconds?.toString() ?? '');
    final restCtrl = TextEditingController(text: re.restSeconds?.toString() ?? '');
    final notesCtrl = TextEditingController(text: re.notes ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(re.exercise.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: TextField(controller: setsCtrl, decoration: const InputDecoration(labelText: 'Series'), keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: repsCtrl, decoration: const InputDecoration(labelText: 'Repeticiones'), keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextField(controller: weightCtrl, decoration: const InputDecoration(labelText: 'Peso (kg)'), keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: durationCtrl, decoration: const InputDecoration(labelText: 'Duracion (seg)'), keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 10),
            TextField(controller: restCtrl, decoration: const InputDecoration(labelText: 'Descanso entre series (seg)'), keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notas / observaciones'), maxLines: 2),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  re.sets = int.tryParse(setsCtrl.text);
                  re.reps = int.tryParse(repsCtrl.text);
                  re.weight = double.tryParse(weightCtrl.text);
                  re.durationSeconds = int.tryParse(durationCtrl.text);
                  re.restSeconds = int.tryParse(restCtrl.text);
                  re.notes = notesCtrl.text.trim();
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      if (widget.routine != null) {
        await _service.update(widget.routine!.id, _nameCtrl.text.trim(), _exercises);
      } else {
        await _service.create(widget.studentId, _nameCtrl.text.trim(), _exercises);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar rutina'),
        content: const Text('Esta accion no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _service.delete(widget.routine!.id);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.routine != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar rutina' : 'Nueva rutina'),
        actions: [
          if (isEdit) IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre de la rutina'),
            ),
          ),
          Expanded(
            child: _exercises.isEmpty
                ? const Center(child: Text('Agrega ejercicios a la rutina'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _exercises.length,
                    itemBuilder: (context, i) {
                      final re = _exercises[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(re.exercise.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            [
                              if (re.sets != null) '${re.sets} series',
                              if (re.reps != null) '${re.reps} reps',
                              if (re.weight != null) '${re.weight} kg',
                              if (re.durationSeconds != null) '${re.durationSeconds}s',
                            ].join(' - '),
                          ),
                          onTap: () => _editExercise(i),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _removeExercise(i),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                OutlinedButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar ejercicio'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Guardar rutina'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
