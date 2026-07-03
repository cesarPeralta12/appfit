import 'package:flutter/material.dart';
import '../../models/diet_note.dart';
import '../../services/diet_service.dart';

const dietTypeLabels = {
  'habit': 'Habito alimenticio',
  'hydration': 'Hidratacion',
  'goal': 'Objetivo nutricional',
};

const dietTypeIcons = {
  'habit': Icons.restaurant_menu,
  'hydration': Icons.water_drop,
  'goal': Icons.flag,
};

class DietTab extends StatefulWidget {
  final int studentId;
  const DietTab({super.key, required this.studentId});

  @override
  State<DietTab> createState() => _DietTabState();
}

class _DietTabState extends State<DietTab> {
  final _service = DietService();
  late Future<List<DietNote>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listByStudent(widget.studentId);
  }

  void _reload() => setState(() { _future = _service.listByStudent(widget.studentId); });

  Future<void> _openForm({DietNote? note}) async {
    String type = note?.type ?? 'habit';
    final ctrl = TextEditingController(text: note?.note ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note == null ? 'Nueva nota de dieta' : 'Editar nota', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: dietTypeLabels.entries.map((e) => ChoiceChip(
                      label: Text(e.value),
                      selected: type == e.key,
                      onSelected: (_) => setSheetState(() => type = e.key),
                    )).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(labelText: 'Nota', alignLabelWithHint: true),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (ctrl.text.trim().isEmpty) return;
                  if (note == null) {
                    await _service.create(widget.studentId, type, ctrl.text.trim());
                  } else {
                    await _service.update(note.id, type, ctrl.text.trim());
                  }
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  _reload();
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _delete(DietNote note) async {
    await _service.delete(note.id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<DietNote>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snap.data ?? [];
          if (notes.isEmpty) {
            return const Center(child: Text('Sin notas de dieta. Agrega la primera.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: notes.length,
            itemBuilder: (context, i) {
              final n = notes[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withValues(alpha: 0.15),
                    child: Icon(dietTypeIcons[n.type] ?? Icons.restaurant_menu, color: Colors.green),
                  ),
                  title: Text(dietTypeLabels[n.type] ?? n.type, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(n.note),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) => v == 'edit' ? _openForm(note: n) : _delete(n),
                    itemBuilder: (ctx) => const [
                      PopupMenuItem(value: 'edit', child: Text('Editar')),
                      PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
