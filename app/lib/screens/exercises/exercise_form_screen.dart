import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../services/exercise_service.dart';
import '../../theme.dart';

class ExerciseFormScreen extends StatefulWidget {
  final Exercise? exercise;
  const ExerciseFormScreen({super.key, this.exercise});

  @override
  State<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends State<ExerciseFormScreen> {
  final _service = ExerciseService();
  late final _nameCtrl = TextEditingController(text: widget.exercise?.name);
  late final _descCtrl = TextEditingController(text: widget.exercise?.description);
  late final _techniqueCtrl = TextEditingController(text: widget.exercise?.technique);
  late final _muscleCtrl = TextEditingController(text: widget.exercise?.muscleGroups.join(', '));
  String _category = 'pesas';
  int _difficulty = 1;
  bool _saving = false;

  final _categories = const {
    'cardio': 'Cardio',
    'pesas': 'Pesas',
    'funcional': 'Funcional',
    'flexibilidad': 'Flexibilidad',
    'tecnica': 'Tecnica',
  };

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      _category = widget.exercise!.category;
      _difficulty = widget.exercise!.difficulty;
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final data = {
      'name': _nameCtrl.text.trim(),
      'category': _category,
      'description': _descCtrl.text.trim(),
      'technique': _techniqueCtrl.text.trim(),
      'muscle_groups': _muscleCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'difficulty': _difficulty,
    };
    try {
      if (widget.exercise != null) {
        await _service.update(widget.exercise!.id, data);
      } else {
        await _service.create(data);
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
        title: const Text('Eliminar ejercicio'),
        content: const Text('Esta accion no se puede deshacer. Deseas continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _service.delete(widget.exercise!.id);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.exercise != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar ejercicio' : 'Nuevo ejercicio'),
        actions: [
          if (isEdit) IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nombre del ejercicio')),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Categoria'),
            items: _categories.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
            onChanged: (v) => setState(() => _category = v ?? 'pesas'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text('Dificultad', style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              ...List.generate(5, (i) => IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      i < _difficulty ? Icons.star : Icons.star_border,
                      color: AppColors.primary,
                    ),
                    onPressed: () => setState(() => _difficulty = i + 1),
                  )),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _muscleCtrl,
            decoration: const InputDecoration(labelText: 'Grupos musculares (separados por coma)'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(
              labelText: 'Explicacion / descripcion',
              hintText: 'Para que sirve este ejercicio, beneficios, etc.',
              alignLabelWithHint: true,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _techniqueCtrl,
            decoration: const InputDecoration(
              labelText: 'Tecnica de ejecucion',
              hintText: 'Como realizarlo correctamente paso a paso',
              alignLabelWithHint: true,
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Guardar ejercicio'),
          ),
        ],
      ),
    );
  }
}
