import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/progress_metric.dart';
import '../../services/progress_metric_service.dart';
import '../../theme.dart';

const metricTypeLabels = {
  'bodyweight': 'Peso corporal',
  'weight': 'Peso levantado',
  'reps': 'Repeticiones',
  'time': 'Tiempo',
  'measurement': 'Medida corporal',
  'imc': 'IMC',
};

const metricTypeIcons = {
  'bodyweight': Icons.monitor_weight,
  'weight': Icons.fitness_center,
  'reps': Icons.repeat,
  'time': Icons.timer,
  'measurement': Icons.straighten,
  'imc': Icons.speed,
};

class StatsTab extends StatefulWidget {
  final int studentId;
  const StatsTab({super.key, required this.studentId});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  final _service = ProgressMetricService();
  late Future<List<ProgressMetric>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listByStudent(widget.studentId);
  }

  void _reload() => setState(() { _future = _service.listByStudent(widget.studentId); });

  Future<void> _openForm() async {
    String type = 'bodyweight';
    final labelCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final unitCtrl = TextEditingController(text: 'kg');
    DateTime date = DateTime.now();

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
                const Text('Nuevo registro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: metricTypeLabels.entries.map((e) => ChoiceChip(
                        label: Text(e.value),
                        selected: type == e.key,
                        onSelected: (_) => setSheetState(() => type = e.key),
                      )).toList(),
                ),
                const SizedBox(height: 12),
                if (type == 'measurement')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextField(
                      controller: labelCtrl,
                      decoration: const InputDecoration(labelText: 'Que se midio (ej. Cintura, Brazo, Pecho)'),
                    ),
                  ),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: valueCtrl,
                      decoration: const InputDecoration(labelText: 'Valor'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: unitCtrl,
                      decoration: const InputDecoration(labelText: 'Unidad (kg, cm, seg, reps)'),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fecha'),
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
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final value = double.tryParse(valueCtrl.text);
                    if (value == null) return;
                    await _service.create({
                      'student_id': widget.studentId,
                      'metric_type': type,
                      'label': type == 'measurement' ? labelCtrl.text.trim() : null,
                      'value': value,
                      'unit': unitCtrl.text.trim(),
                      'recorded_at': date.toIso8601String().split('T').first,
                    });
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

  static const _months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  String _formatDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  Widget _chartFor(String type, List<ProgressMetric> metrics) {
    final sorted = [...metrics]..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    if (sorted.length < 2) return const SizedBox.shrink();
    final spots = <FlSpot>[];
    for (var i = 0; i < sorted.length; i++) {
      spots.add(FlSpot(i.toDouble(), sorted[i].value));
    }
    return SizedBox(
      height: 140,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.1)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<ProgressMetric>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final metrics = snap.data ?? [];
          if (metrics.isEmpty) {
            return const Center(child: Text('Sin registros aun. Agrega peso, medidas o marcas.'));
          }
          final grouped = <String, List<ProgressMetric>>{};
          for (final m in metrics) {
            final key = m.metricType == 'measurement' ? 'measurement:${m.label}' : m.metricType;
            grouped.putIfAbsent(key, () => []).add(m);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: grouped.entries.map((entry) {
              final items = [...entry.value]..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
              final type = entry.key.split(':').first;
              final title = type == 'measurement' ? (items.first.label ?? 'Medida') : (metricTypeLabels[type] ?? type);
              final latest = items.first;
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(metricTypeIcons[type] ?? Icons.show_chart, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
                        Text('${latest.value} ${latest.unit ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ]),
                      _chartFor(entry.key, items),
                      const SizedBox(height: 4),
                      Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: EdgeInsets.zero,
                          title: Text('Ver historial (${items.length})',
                              style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
                          children: items
                              .map((m) => ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text('${m.value} ${m.unit ?? ''}', style: const TextStyle(fontSize: 14)),
                                    subtitle: Text(_formatDate(m.recordedAt), style: const TextStyle(fontSize: 12)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                      onPressed: () => _delete(m.id),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _openForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
