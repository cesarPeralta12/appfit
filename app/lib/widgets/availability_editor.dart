import 'package:flutter/material.dart';
import '../models/student.dart';

const dayLabels = {
  'mon': 'Lunes',
  'tue': 'Martes',
  'wed': 'Miercoles',
  'thu': 'Jueves',
  'fri': 'Viernes',
  'sat': 'Sabado',
  'sun': 'Domingo',
};

class AvailabilityEditor extends StatefulWidget {
  final List<AvailabilitySlot> initial;
  final ValueChanged<List<AvailabilitySlot>> onChanged;

  const AvailabilityEditor({super.key, required this.initial, required this.onChanged});

  @override
  State<AvailabilityEditor> createState() => _AvailabilityEditorState();
}

class _AvailabilityEditorState extends State<AvailabilityEditor> {
  late List<AvailabilitySlot> _slots;

  @override
  void initState() {
    super.initState();
    _slots = widget.initial.map((s) => AvailabilitySlot(day: s.day, start: s.start, end: s.end)).toList();
  }

  void _notify() => widget.onChanged(_slots);

  Future<void> _pickTime(AvailabilitySlot slot, bool isStart) async {
    final current = isStart ? slot.start : slot.end;
    final parts = current.split(':');
    final initial = TimeOfDay(hour: int.tryParse(parts[0]) ?? 18, minute: int.tryParse(parts[1]) ?? 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) {
          slot.start = formatted;
        } else {
          slot.end = formatted;
        }
      });
      _notify();
    }
  }

  void _addSlot() {
    setState(() => _slots.add(AvailabilitySlot(day: 'mon', start: '18:00', end: '19:00')));
    _notify();
  }

  void _removeSlot(int index) {
    setState(() => _slots.removeAt(index));
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _slots.length; i++)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: const Color(0xFFFFF3EC),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _slots[i].day,
                        items: dayLabels.entries
                            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _slots[i].day = v ?? 'mon');
                          _notify();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _pickTime(_slots[i], true),
                      child: Text(_slots[i].start),
                    ),
                  ),
                  const Text('-'),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _pickTime(_slots[i], false),
                      child: Text(_slots[i].end),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeSlot(i),
                  ),
                ],
              ),
            ),
          ),
        TextButton.icon(
          onPressed: _addSlot,
          icon: const Icon(Icons.add),
          label: const Text('Agregar horario'),
        ),
      ],
    );
  }
}
