import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../config.dart';
import '../../models/routine.dart';
import '../../models/student.dart';
import '../../services/student_service.dart';
import '../../theme.dart';
import '../../widgets/availability_editor.dart';
import 'diet_tab.dart';
import 'injury_tab.dart';
import 'routine_edit_screen.dart';
import 'stats_tab.dart';
import 'student_form_screen.dart';

const _kPrimary = AppColors.primary;

const _ageCategoryColors = {
  'nino': Color(0xFF3B82F6),
  'joven': Color(0xFF8B5CF6),
  'adulto': Color(0xFF14181F),
};

class StudentDetailScreen extends StatefulWidget {
  final int studentId;
  const StudentDetailScreen({super.key, required this.studentId});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final _service = StudentService();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.show(widget.studentId);
  }

  void _reload() => setState(() { _future = _service.show(widget.studentId); });

  String _photoUrl(String path) => path.startsWith('http') ? path : '${ApiConfig.host}$path';

  Future<void> _changePhoto(int studentId) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    final file = result?.files.single;
    if (file?.bytes == null) return;
    try {
      await _service.uploadPhoto(studentId, file!.bytes!, file.name);
      _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo subir la foto: $e')));
      }
    }
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'advanced':
        return const Color(0xFF7C3AED);
      case 'intermediate':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF16A34A);
    }
  }

  String _levelLabel(String level) {
    switch (level) {
      case 'advanced':
        return 'Avanzado';
      case 'intermediate':
        return 'Intermedio';
      default:
        return 'Principiante';
    }
  }

  Widget _miniStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(title: const Text('Alumno')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final data = snap.data!;
          final student = Student.fromJson(data);
          final routines = data['routines'] as List? ?? [];
          final ageColor = _ageCategoryColors[student.ageCategory] ?? Colors.grey;

          return DefaultTabController(
            length: 5,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => _changePhoto(student.id),
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: _levelColor(student.level).withValues(alpha: 0.12),
                                  backgroundImage: student.photo != null ? NetworkImage(_photoUrl(student.photo!)) : null,
                                  child: student.photo == null
                                      ? Text(
                                          student.name.isNotEmpty ? student.name[0] : '?',
                                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _levelColor(student.level)),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: _kPrimary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.camera_alt, size: 13, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(student.name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    Chip(
                                      label: Text(_levelLabel(student.level), style: const TextStyle(color: Colors.white, fontSize: 11)),
                                      backgroundColor: _levelColor(student.level),
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    Chip(
                                      label: Text(ageCategoryLabels[student.ageCategory] ?? student.ageCategory,
                                          style: const TextStyle(color: Colors.white, fontSize: 11)),
                                      backgroundColor: ageColor,
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.grey),
                            onPressed: () async {
                              final changed = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(builder: (_) => StudentFormScreen(student: student)),
                              );
                              if (changed == true) _reload();
                            },
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      Row(
                        children: [
                          _miniStat('Peso', student.weight != null ? '${student.weight} kg' : '-', Icons.monitor_weight_outlined),
                          _miniStat('Altura', student.height != null ? '${student.height} cm' : '-', Icons.height),
                          _miniStat('IMC', student.imc != null ? student.imc!.toStringAsFixed(1) : '-', Icons.speed_outlined),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const TabBar(
                    indicatorColor: _kPrimary,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: _kPrimary,
                    unselectedLabelColor: Colors.grey,
                    isScrollable: true,
                    tabs: [
                      Tab(text: 'Perfil'),
                      Tab(text: 'Rutinas'),
                      Tab(text: 'Estadisticas'),
                      Tab(text: 'Dietas'),
                      Tab(text: 'Lesiones'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _profileTab(student),
                      _routinesTab(student.id, routines),
                      StatsTab(studentId: student.id),
                      DietTab(studentId: student.id),
                      InjuryTab(studentId: student.id),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 10),
            SizedBox(width: 110, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
            Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      );

  Widget _profileTab(Student s) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Datos generales', style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                _infoRow(Icons.phone, 'Telefono', s.phone ?? '-'),
                _infoRow(Icons.flag, 'Objetivo', s.goal ?? '-'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: const [
                  Icon(Icons.schedule, size: 18, color: _kPrimary),
                  SizedBox(width: 8),
                  Text('Disponibilidad horaria', style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 10),
                if (s.availability.isEmpty)
                  const Text('Sin horarios definidos. Editalo desde el lapiz.', style: TextStyle(color: Colors.grey))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: s.availability
                        .map((a) => Chip(
                              avatar: const Icon(Icons.access_time, size: 16),
                              label: Text('${dayLabels[a.day] ?? a.day} ${a.start}-${a.end}'),
                              backgroundColor: const Color(0xFFFFF3EC),
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: const [
                  Icon(Icons.medical_information, size: 18, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text('Informacion medica', style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
                const Divider(),
                _infoRow(Icons.warning_amber, 'Alergias', s.allergies?.isNotEmpty == true ? s.allergies! : 'Ninguna registrada'),
                _infoRow(Icons.healing, 'Patologias', s.pathologies?.isNotEmpty == true ? s.pathologies! : 'Ninguna registrada'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _routinesTab(int studentId, List routinesJson) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: routinesJson.isEmpty
          ? const Center(child: Text('Sin rutinas asignadas. Crea la primera.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: routinesJson.length,
              itemBuilder: (context, i) {
                final r = routinesJson[i];
                final exercises = (r['exercises'] as List?) ?? [];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text(r['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${exercises.length} ejercicios'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () async {
                            final routine = Routine.fromJson(r);
                            final changed = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(builder: (_) => RoutineEditScreen(studentId: studentId, routine: routine)),
                            );
                            if (changed == true) _reload();
                          },
                        ),
                        const Icon(Icons.expand_more),
                      ],
                    ),
                    children: exercises.map<Widget>((re) {
                      final ex = re['exercise'];
                      final parts = [
                        if (re['sets'] != null) '${re['sets']} series',
                        if (re['reps'] != null) '${re['reps']} reps',
                        if (re['weight'] != null) '${re['weight']} kg',
                        if (re['duration_seconds'] != null) '${re['duration_seconds']}s',
                      ].join(' - ');
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.fitness_center, size: 18),
                        title: Text(ex?['name'] ?? ''),
                        subtitle: Text(parts.isEmpty ? '-' : parts),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () async {
          final changed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => RoutineEditScreen(studentId: studentId)),
          );
          if (changed == true) _reload();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
