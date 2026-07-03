import 'package:flutter/material.dart';
import '../../services/api_client.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final res = await ApiClient().dio.get('/reports/overview');
    return res.data;
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final d = snap.data!;
          final byLevel = Map<String, dynamic>.from(d['by_level'] ?? {});
          return RefreshIndicator(
            onRefresh: () async => setState(() { _future = _load(); }),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(children: [
                  _statCard('Alumnos totales', '${d['total_students']}', Icons.people, Colors.blue),
                  const SizedBox(width: 12),
                  _statCard('Activos', '${d['active_students']}', Icons.check_circle, Colors.green),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  _statCard('Sesiones este mes', '${d['sessions_this_month']}', Icons.event, Colors.orange),
                  const SizedBox(width: 12),
                  _statCard('Completadas', '${d['completed_this_month']}', Icons.fact_check, Colors.purple),
                ]),
                const SizedBox(height: 20),
                const Text('Alumnos por nivel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...byLevel.entries.map((e) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(e.key),
                        trailing: Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
