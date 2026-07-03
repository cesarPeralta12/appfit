import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/training_session.dart';
import '../../services/session_service.dart';
import '../../theme.dart';
import 'calendar_tab.dart';
import 'session_form_screen.dart';
import 'session_live_screen.dart';

class SessionsListScreen extends StatefulWidget {
  const SessionsListScreen({super.key});

  @override
  State<SessionsListScreen> createState() => _SessionsListScreenState();
}

class _SessionsListScreenState extends State<SessionsListScreen> {
  final _service = SessionService();
  late Future<List<TrainingSession>> _future;
  final _df = DateFormat('dd/MM HH:mm');

  @override
  void initState() {
    super.initState();
    _future = _service.list();
  }

  void _reload() => setState(() { _future = _service.list(); });

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sesiones'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'Lista'),
              Tab(icon: Icon(Icons.calendar_month), text: 'Calendario'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _listView(),
            const CalendarTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final created = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const SessionFormScreen()),
            );
            if (created == true) _reload();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _listView() {
    return FutureBuilder<List<TrainingSession>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final sessions = snap.data ?? [];
        if (sessions.isEmpty) {
          return const Center(child: Text('No hay sesiones programadas'));
        }
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sessions.length,
            itemBuilder: (context, i) {
              final s = sessions[i];
              final studentName = s.student?['name'] ?? 'Sesion grupal';
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(s.status).withValues(alpha: 0.15),
                    child: Icon(Icons.event, color: _statusColor(s.status)),
                  ),
                  title: Text(studentName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${s.type} - ${_df.format(s.scheduledAt)}'),
                  trailing: Chip(
                    label: Text(s.status, style: const TextStyle(fontSize: 11, color: Colors.white)),
                    backgroundColor: _statusColor(s.status),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => SessionLiveScreen(sessionId: s.id)),
                  ).then((_) => _reload()),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
