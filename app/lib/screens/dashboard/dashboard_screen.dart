import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';
import '../../theme.dart';
import '../../widgets/app_logo.dart';
import '../exercises/exercises_list_screen.dart';
import '../reports/reports_screen.dart';
import '../sessions/sessions_list_screen.dart';
import '../students/students_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;

  _MenuItem({required this.title, required this.subtitle, required this.icon, required this.color, required this.builder});
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _overview;

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  Future<void> _loadOverview() async {
    try {
      final res = await ApiClient().dio.get('/reports/overview');
      setState(() => _overview = res.data);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    final items = [
      _MenuItem(
        title: 'Sesiones',
        subtitle: 'Calendario y entrenamientos',
        icon: Icons.event_available,
        color: AppColors.success,
        builder: (_) => const SessionsListScreen(),
      ),
      _MenuItem(
        title: 'Ejercicios',
        subtitle: 'Banco de ejercicios',
        icon: Icons.fitness_center,
        color: AppColors.primary,
        builder: (_) => const ExercisesListScreen(),
      ),
      _MenuItem(
        title: 'Alumnos',
        subtitle: 'Perfiles y progreso',
        icon: Icons.people_alt,
        color: AppColors.info,
        builder: (_) => const StudentsListScreen(),
      ),
      _MenuItem(
        title: 'Reportes',
        subtitle: 'Estadisticas generales',
        icon: Icons.bar_chart,
        color: AppColors.violet,
        builder: (_) => const ReportsScreen(),
      ),
    ];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadOverview,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: const BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AppLogo(size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Hola, ${user?.name.split(' ').first ?? ''}',
                              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (_overview != null)
                      Row(
                        children: [
                          Expanded(
                              child: _statCard('Alumnos activos', '${_overview!['active_students']}', Icons.people)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _statCard('Sesiones del mes', '${_overview!['sessions_this_month']}', Icons.event)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Accesos rapidos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ...items.map((item) => _menuRow(context, item)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _menuRow(BuildContext context, _MenuItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: item.builder)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: item.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(item.icon, color: item.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(item.subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
