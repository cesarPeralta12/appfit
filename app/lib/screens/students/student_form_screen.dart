import 'package:flutter/material.dart';
import '../../models/student.dart';
import '../../services/student_service.dart';
import '../../theme.dart';
import '../../widgets/availability_editor.dart';

const ageCategoryLabels = {
  'nino': 'Niño',
  'joven': 'Joven',
  'adulto': 'Adulto',
};

class StudentFormScreen extends StatefulWidget {
  final Student? student;
  const StudentFormScreen({super.key, this.student});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _service = StudentService();
  late final _nameCtrl = TextEditingController(text: widget.student?.name);
  late final _goalCtrl = TextEditingController(text: widget.student?.goal);
  late final _weightCtrl = TextEditingController(text: widget.student?.weight?.toString());
  late final _heightCtrl = TextEditingController(text: widget.student?.height?.toString());
  late final _phoneCtrl = TextEditingController(text: widget.student?.phone);
  late final _allergiesCtrl = TextEditingController(text: widget.student?.allergies);
  late final _pathologiesCtrl = TextEditingController(text: widget.student?.pathologies);
  String _level = 'beginner';
  String _ageCategory = 'adulto';
  String? _sex;
  List<AvailabilitySlot> _availability = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _level = widget.student!.level;
      _ageCategory = widget.student!.ageCategory;
      _sex = widget.student!.sex;
      _availability = widget.student!.availability
          .map((s) => AvailabilitySlot(day: s.day, start: s.start, end: s.end))
          .toList();
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final data = {
      'name': _nameCtrl.text.trim(),
      'goal': _goalCtrl.text.trim(),
      'level': _level,
      'age_category': _ageCategory,
      'sex': _sex,
      'phone': _phoneCtrl.text.trim(),
      'allergies': _allergiesCtrl.text.trim(),
      'pathologies': _pathologiesCtrl.text.trim(),
      'weight': double.tryParse(_weightCtrl.text),
      'height': double.tryParse(_heightCtrl.text),
      'availability': _availability.map((e) => e.toJson()).toList(),
    };
    try {
      if (widget.student != null) {
        await _service.update(widget.student!.id, data);
      } else {
        await _service.create(Student(
          id: 0,
          name: data['name'] as String,
          level: _level,
          ageCategory: _ageCategory,
          sex: _sex,
          goal: data['goal'] as String?,
          phone: data['phone'] as String?,
          allergies: data['allergies'] as String?,
          pathologies: data['pathologies'] as String?,
          weight: data['weight'] as double?,
          height: data['height'] as double?,
          availability: _availability,
        ));
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

  Widget _sectionTitle(String text, IconData icon) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.student == null ? 'Nuevo alumno' : 'Editar alumno')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Datos basicos', Icons.person),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nombre completo')),
          const SizedBox(height: 12),
          TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Telefono')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _sex,
                decoration: const InputDecoration(labelText: 'Sexo'),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Masculino')),
                  DropdownMenuItem(value: 'female', child: Text('Femenino')),
                  DropdownMenuItem(value: 'other', child: Text('Otro')),
                ],
                onChanged: (v) => setState(() => _sex = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _ageCategory,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: ageCategoryLabels.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (v) => setState(() => _ageCategory = v ?? 'adulto'),
              ),
            ),
          ]),
          const SizedBox(height: 18),
          _sectionTitle('Entrenamiento', Icons.fitness_center),
          TextField(controller: _goalCtrl, decoration: const InputDecoration(labelText: 'Objetivo (perdida de peso, etc.)')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _level,
            decoration: const InputDecoration(labelText: 'Nivel'),
            items: const [
              DropdownMenuItem(value: 'beginner', child: Text('Principiante')),
              DropdownMenuItem(value: 'intermediate', child: Text('Intermedio')),
              DropdownMenuItem(value: 'advanced', child: Text('Avanzado')),
            ],
            onChanged: (v) => setState(() => _level = v ?? 'beginner'),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _weightCtrl, decoration: const InputDecoration(labelText: 'Peso (kg)'), keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _heightCtrl, decoration: const InputDecoration(labelText: 'Altura (cm)'), keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 18),
          _sectionTitle('Disponibilidad horaria', Icons.schedule),
          AvailabilityEditor(initial: _availability, onChanged: (v) => _availability = v),
          const SizedBox(height: 18),
          _sectionTitle('Informacion medica', Icons.medical_information),
          TextField(controller: _allergiesCtrl, decoration: const InputDecoration(labelText: 'Alergias'), maxLines: 2),
          const SizedBox(height: 12),
          TextField(controller: _pathologiesCtrl, decoration: const InputDecoration(labelText: 'Patologias (asma, diabetes, etc.)'), maxLines: 2),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
