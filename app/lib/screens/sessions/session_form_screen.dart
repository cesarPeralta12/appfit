import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/exercise.dart';
import '../../models/student.dart';
import '../../services/exercise_service.dart';
import '../../services/session_service.dart';
import '../../services/student_service.dart';
import '../../theme.dart';

class SessionFormScreen extends StatefulWidget {
  final int? preselectedStudentId;
  const SessionFormScreen({super.key, this.preselectedStudentId});

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _ExerciseDraft {
  final Exercise exercise;
  int? sets;
  int? reps;
  double? weight;

  _ExerciseDraft({required this.exercise, this.sets = 3, this.reps = 10, this.weight});
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  final _studentService = StudentService();
  final _exerciseService = ExerciseService();
  final _sessionService = SessionService();
  final _notesCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '60');

  static const _typeLabels = {
    'fuerza': 'Fuerza',
    'cardio': 'Cardio',
    'mixta': 'Mixta',
    'recuperacion': 'Recuperacion',
  };

  List<Student> _students = [];
  Student? _selectedStudent;
  String _type = 'fuerza';
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  final List<_ExerciseDraft> _exercises = [];
  bool _loadingStudents = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final students = await _studentService.list();
      Student? preselected;
      for (final s in students) {
        if (s.id == widget.preselectedStudentId) {
          preselected = s;
          break;
        }
      }
      setState(() {
        _students = students;
        _selectedStudent = preselected;
        _loadingStudents = false;
      });
    } catch (_) {
      setState(() => _loadingStudents = false);
    }
  }

  Future<void> _pickStudent() async {
    final selected = await showModalBottomSheet<Student>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (ctx, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Elegir alumno', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: _students.isEmpty
                    ? const Center(child: Text('No hay alumnos. Crea uno primero.'))
                    : ListView.builder(
                        controller: scrollCtrl,
                        itemCount: _students.length,
                        itemBuilder: (context, i) {
                          final s = _students[i];
                          return ListTile(
                            title: Text(s.name),
                            subtitle: Text(s.goal ?? 'Sin objetivo'),
                            onTap: () => Navigator.of(ctx).pop(s),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) setState(() => _selectedStudent = selected);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _addExercise() async {
    final exercises = await _exerciseService.list();
    if (!mounted) return;
    final selected = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
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
                    ? const Center(child: Text('No hay ejercicios en el banco.\nCrea uno primero desde "Ejercicios".', textAlign: TextAlign.center))
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
      setState(() => _exercises.add(_ExerciseDraft(exercise: selected)));
    }
  }

  void _removeExercise(int index) => setState(() => _exercises.removeAt(index));

  Future<void> _save() async {
    if (_selectedStudent == null) {
      setState(() => _error = 'Elige un alumno');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final scheduledAt = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    try {
      await _sessionService.create({
        'student_id': _selectedStudent!.id,
        'type': _type,
        'scheduled_at': scheduledAt.toIso8601String(),
        'duration_minutes': int.tryParse(_durationCtrl.text),
        'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        'exercises': _exercises
            .map((e) => {
                  'exercise_id': e.exercise.id,
                  'planned_sets': e.sets,
                  'planned_reps': e.reps,
                  'planned_weight': e.weight,
                })
            .toList(),
      });
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'No se pudo guardar la sesion. Intenta de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva sesion')),
      body: _loadingStudents
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Alumno', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _pickStudent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedStudent?.name ?? 'Seleccionar alumno',
                            style: TextStyle(color: _selectedStudent == null ? Colors.grey : AppColors.ink, fontSize: 16),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Tipo', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _type,
                      isExpanded: true,
                      items: _typeLabels.entries
                          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                          .toList(),
                      onChanged: (v) => setState(() => _type = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fecha', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: Text(DateFormat('dd/MM/yyyy').format(_date)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hora', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: Text(_time.format(context)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _durationCtrl,
                  decoration: const InputDecoration(labelText: 'Duracion (minutos)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(labelText: 'Notas (opcional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Ejercicios (opcional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _addExercise,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Agregar'),
                    ),
                  ],
                ),
                if (_exercises.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Sin ejercicios asignados', style: TextStyle(color: Colors.grey)),
                  )
                else
                  ..._exercises.asMap().entries.map((entry) {
                    final i = entry.key;
                    final e = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(e.exercise.name),
                        subtitle: Text('${e.sets ?? 0} series x ${e.reps ?? 0} reps'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _removeExercise(i),
                        ),
                      ),
                    );
                  }),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Guardar sesion'),
                ),
              ],
            ),
    );
  }
}
