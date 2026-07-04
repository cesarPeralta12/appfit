import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/training_session.dart';
import '../../services/session_service.dart';
import '../../theme.dart';
import 'session_live_screen.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  final _service = SessionService();
  Map<DateTime, List<TrainingSession>> _byDay = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _loading = true;
  final _timeFmt = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _load();
  }

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _load() async {
    final sessions = await _service.list();
    final map = <DateTime, List<TrainingSession>>{};
    for (final s in sessions) {
      final key = _dayKey(s.scheduledAt);
      map.putIfAbsent(key, () => []).add(s);
    }
    setState(() {
      _byDay = map;
      _loading = false;
    });
  }

  List<TrainingSession> _sessionsFor(DateTime day) => _byDay[_dayKey(day)] ?? [];

  static const _weekdays = ['Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo'];
  static const _months = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  String _formatSpanishDate(DateTime d) =>
      '${_weekdays[d.weekday - 1]} ${d.day} de ${_months[d.month - 1]}';

  Color _statusColor(String s) {
    switch (s) {
      case 'completed':
        return Colors.green;
      case 'missed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final daySessions = _sessionsFor(_selectedDay ?? DateTime.now());

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: TableCalendar<TrainingSession>(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => _selectedDay != null && _dayKey(day) == _dayKey(_selectedDay!),
              eventLoader: _sessionsFor,
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              onPageChanged: (focused) => _focusedDay = focused,
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(color: Color(0xFFFFD3B0), shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                markerDecoration: BoxDecoration(color: Color(0xFF14181F), shape: BoxShape.circle),
              ),
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _selectedDay != null ? _formatSpanishDate(_selectedDay!) : '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          if (daySessions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('No hay entrenamientos este dia', style: TextStyle(color: Colors.grey)),
            )
          else
            ...daySessions.map((s) {
              final name = s.student?['name'] ?? 'Sesion grupal';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(s.status).withValues(alpha: 0.15),
                      child: Icon(Icons.fitness_center, color: _statusColor(s.status)),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${_timeFmt.format(s.scheduledAt)} - ${s.type}'),
                    trailing: Chip(
                      label: Text(s.status, style: const TextStyle(fontSize: 11, color: Colors.white)),
                      backgroundColor: _statusColor(s.status),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => SessionLiveScreen(sessionId: s.id)),
                    ).then((_) => _load()),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
