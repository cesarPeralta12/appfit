import 'package:flutter/material.dart';
import '../../services/injury_service.dart';

const injuryStatusLabels = {
  'active': 'Activa',
  'recovering': 'En recuperacion',
  'recovered': 'Recuperada',
};

class InjuryTab extends StatefulWidget {
  final int studentId;
  const InjuryTab({super.key, required this.studentId});

  @override
  State<InjuryTab> createState() => _InjuryTabState();
}

class _InjuryTabState extends State<InjuryTab> {
  final _service = InjuryService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listByStudent(widget.studentId);
  }

  void _reload() => setState(() { _future = _service.listByStudent(widget.studentId); });

  Color _statusColor(String status) {
    switch (status) {
      case 'recovered':
        return Colors.green;
      case 'recovering':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  Future<void> _openForm({Map<String, dynamic>? injury}) async {
    final descCtrl = TextEditingController(text: injury?['description'] ?? '');
    final planCtrl = TextEditingController(text: injury?['recovery_plan'] ?? '');
    final notesCtrl = TextEditingController(text: injury?['notes'] ?? '');
    DateTime date = injury?['date_occurred'] != null ? DateTime.parse(injury!['date_occurred']) : DateTime.now();
    String status = injury?['status'] ?? 'active';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(injury == null ? 'Nueva lesion' : 'Editar lesion', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripcion')),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fecha de ocurrencia'),
                  subtitle: Text('${date.day}/${date.month}/${date.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx, initialDate: date,
                      firstDate: DateTime(2015), lastDate: DateTime(2035),
                    );
                    if (picked != null) setSheetState(() => date = picked);
                  },
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: injuryStatusLabels.entries.map((e) => ChoiceChip(
                        label: Text(e.value),
                        selected: status == e.key,
                        onSelected: (_) => setSheetState(() => status = e.key),
                      )).toList(),
                ),
                const SizedBox(height: 10),
                TextField(controller: planCtrl, decoration: const InputDecoration(labelText: 'Plan de recuperacion / ejercicios restringidos'), maxLines: 2),
                const SizedBox(height: 10),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notas de evolucion'), maxLines: 2),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (descCtrl.text.trim().isEmpty) return;
                    final data = {
                      'description': descCtrl.text.trim(),
                      'date_occurred': date.toIso8601String().split('T').first,
                      'status': status,
                      'recovery_plan': planCtrl.text.trim(),
                      'notes': notesCtrl.text.trim(),
                    };
                    if (injury == null) {
                      await _service.create(widget.studentId, data);
                    } else {
                      await _service.update(injury['id'], data);
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
      ),
    );
  }

  Future<void> _delete(int id) async {
    await _service.delete(id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final injuries = snap.data ?? [];
          if (injuries.isEmpty) {
            return const Center(child: Text('Sin lesiones registradas. Agrega la primera.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: injuries.length,
            itemBuilder: (context, i) {
              final inj = injuries[i];
              final color = _statusColor(inj['status']);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(Icons.healing, color: color)),
                  title: Text(inj['description'] ?? ''),
                  subtitle: Text('${injuryStatusLabels[inj['status']] ?? inj['status']} - ${inj['date_occurred']}'),
                  onTap: () => _openForm(injury: inj),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) => v == 'edit' ? _openForm(injury: inj) : _delete(inj['id']),
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
