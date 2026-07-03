import 'package:flutter/material.dart';
import '../../config.dart';
import '../../models/student.dart';
import '../../services/student_service.dart';
import 'student_detail_screen.dart';
import 'student_form_screen.dart';

const _ageCategoryIcons = {
  'nino': Icons.child_care,
  'joven': Icons.emoji_people,
  'adulto': Icons.person,
};

const _ageCategoryFilterLabels = {
  null: 'Todas las edades',
  'nino': 'Niños',
  'joven': 'Jovenes',
  'adulto': 'Adultos',
};

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  final _service = StudentService();
  late Future<List<Student>> _future;
  final _searchCtrl = TextEditingController();
  String? _ageFilter;

  @override
  void initState() {
    super.initState();
    _future = _service.list();
  }

  void _reload() {
    setState(() { _future = _service.list(search: _searchCtrl.text, ageCategory: _ageFilter); });
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'advanced':
        return Colors.deepPurple;
      case 'intermediate':
        return Colors.blue;
      default:
        return Colors.green;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alumnos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar alumno...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () {
                  _searchCtrl.clear();
                  _reload();
                }),
              ),
              onSubmitted: (_) => _reload(),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _ageCategoryFilterLabels.entries.map((e) {
                final selected = _ageFilter == e.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(e.value),
                    selected: selected,
                    onSelected: (_) {
                      _ageFilter = e.key;
                      _reload();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Student>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final students = snap.data ?? [];
                if (students.isEmpty) {
                  return const Center(child: Text('No hay alumnos aun'));
                }
                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: students.length,
                    itemBuilder: (context, i) {
                      final s = students[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => StudentDetailScreen(studentId: s.id)),
                          ).then((_) => _reload()),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: _levelColor(s.level).withValues(alpha: 0.15),
                                  backgroundImage: s.photo != null
                                      ? NetworkImage(s.photo!.startsWith('http') ? s.photo! : '${ApiConfig.host}${s.photo}')
                                      : null,
                                  child: s.photo == null
                                      ? Text(s.name.isNotEmpty ? s.name[0] : '?',
                                          style: TextStyle(color: _levelColor(s.level), fontWeight: FontWeight.bold, fontSize: 18))
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Icon(_ageCategoryIcons[s.ageCategory] ?? Icons.person, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(s.goal ?? 'Sin objetivo definido',
                                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                                                overflow: TextOverflow.ellipsis),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Chip(
                                  label: Text(_levelLabel(s.level), style: const TextStyle(fontSize: 11, color: Colors.white)),
                                  backgroundColor: _levelColor(s.level),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
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
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const StudentFormScreen()),
        ).then((_) => _reload()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
