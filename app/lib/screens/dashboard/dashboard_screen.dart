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
        title: 'Alumnos',
        subtitle: 'Perfiles y progreso',
        icon: Icons.people_alt,
        color: AppColors.info,
        builder: (_) => const StudentsListScreen(),
      ),
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
        title: 'Reportes',
        subtitle: 'Estadisticas generales',
        icon: Icons.bar_chart,
        color: AppColors.violet,
        builder: (_) => const ReportsScreen(),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadOverview,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Row(
                children: [
                  const AppLogo(size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hola, ${user?.name.split(' ').first ?? ''}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const Text('Que entrenemos hoy', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_overview != null)
                Row(
                  children: [
                    Expanded(child: _statCard('Alumnos activos', '${_overview!['active_students']}', Icons.people, AppColors.info)),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('Sesiones del mes', '${_overview!['sessions_this_month']}', Icons.event, AppColors.success)),
                  ],
                ),
              const SizedBox(height: 24),
              const Text('Tu panel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.05,
                children: items.map((item) => _menuCard(context, item)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, _MenuItem item) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: item.builder)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: item.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(item.icon, color: item.color),
              ),
              const Spacer(),
              Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 2),
              Text(item.subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
