import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/training_session.dart';
import '../../services/session_service.dart';
import '../../theme.dart';

class SessionLiveScreen extends StatefulWidget {
  final int sessionId;
  const SessionLiveScreen({super.key, required this.sessionId});

  @override
  State<SessionLiveScreen> createState() => _SessionLiveScreenState();
}

class _SessionLiveScreenState extends State<SessionLiveScreen> {
  final _service = SessionService();
  TrainingSession? _session;
  bool _loading = true;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final s = await _service.show(widget.sessionId);
    setState(() {
      _session = s;
      _loading = false;
    });
  }

  void _toggleTimer() {
    if (_running) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed += const Duration(seconds: 1));
      });
      _service.start(widget.sessionId);
    }
    setState(() => _running = !_running);
  }

  Future<void> _finishSession() async {
    _timer?.cancel();
    await _service.finish(widget.sessionId);
    if (mounted) Navigator.of(context).pop();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<void> _logSet(SessionExercise se, int setNumber) async {
    final repsCtrl = TextEditingController(text: se.plannedReps?.toString() ?? '');
    final weightCtrl = TextEditingController(text: se.plannedWeight?.toString() ?? '');
    String effort = 'normal';
    bool techniqueOk = true;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${se.exercise.name} - Serie $setNumber', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: TextField(controller: repsCtrl, decoration: const InputDecoration(labelText: 'Repeticiones'), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: weightCtrl, decoration: const InputDecoration(labelText: 'Peso (kg)'), keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 16),
              const Text('Esfuerzo percibido', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: const [
                  ['facil', 'Facil'], ['normal', 'Normal'], ['dificil', 'Dificil'], ['muy_dificil', 'Muy dificil'],
                ].map((e) => ChoiceChip(
                      label: Text(e[1]),
                      selected: effort == e[0],
                      onSelected: (_) => setSheetState(() => effort = e[0]),
                    )).toList(),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tecnica correcta'),
                value: techniqueOk,
                onChanged: (v) => setSheetState(() => techniqueOk = v),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await _service.logSet(se.id, {
                    'set_number': setNumber,
                    'reps_done': int.tryParse(repsCtrl.text),
                    'weight_used': double.tryParse(weightCtrl.text),
                    'effort': effort,
                    'technique_ok': techniqueOk,
                    'completed': true,
                  });
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  _load();
                },
                child: const Text('Guardar serie'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final s = _session!;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.student?['name'] ?? 'Sesion'),
        actions: [
          IconButton(icon: const Icon(Icons.check_circle), onPressed: _finishSession, tooltip: 'Finalizar sesion'),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF14181F),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Text(_fmt(_elapsed), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _toggleTimer,
                  icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                  label: Text(_running ? 'Pausar' : 'Iniciar entrenamiento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _running ? Colors.amber : AppColors.primary,
                    minimumSize: const Size(220, 48),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: s.exercises.length,
              itemBuilder: (context, i) {
                final se = s.exercises[i];
                final sets = se.plannedSets ?? 3;
                final completedCount = se.logs.where((l) => l.completed).length;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(se.exercise.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                            Text('$completedCount/$sets', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        Text('${se.plannedSets ?? '-'} series x ${se.plannedReps ?? '-'} reps', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(sets, (idx) {
                            final setNum = idx + 1;
                            final done = se.logs.any((l) => l.setNumber == setNum && l.completed);
                            return ActionChip(
                              avatar: Icon(done ? Icons.check_circle : Icons.circle_outlined,
                                  color: done ? Colors.green : Colors.grey, size: 18),
                              label: Text('Serie $setNum'),
                              onPressed: () => _logSet(se, setNum),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
