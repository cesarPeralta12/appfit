import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';
import '../../widgets/app_logo.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'student':
        return 'Alumno';
      default:
        return 'Entrenador';
    }
  }

  String _photoUrl(String path) => path.startsWith('http') ? path : '${ApiConfig.host}$path';

  Future<void> _changePhoto(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    final file = result?.files.single;
    if (file?.bytes == null) return;
    final ok = await context.read<AuthProvider>().uploadPhoto(file!.bytes!, file.name);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo subir la foto')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi cuenta')),
      body: user == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _changePhoto(context),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.white,
                              backgroundImage: user.photo != null ? NetworkImage(_photoUrl(user.photo!)) : null,
                              child: user.photo == null
                                  ? Text(
                                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDark,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, size: 13, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(_roleLabel(user.role), style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Column(
                    children: [
                      _infoTile(Icons.email_outlined, 'Correo electronico', user.email),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _infoTile(Icons.phone_outlined, 'Telefono', user.phone?.isNotEmpty == true ? user.phone! : 'No registrado'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: () => context.read<AuthProvider>().logout(),
                  icon: const Icon(Icons.logout, color: AppColors.danger),
                  label: const Text('Cerrar sesion', style: TextStyle(color: AppColors.danger)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    side: const BorderSide(color: AppColors.danger),
                  ),
                ),
                const SizedBox(height: 32),
                const Center(child: AppLogo(size: 40)),
                const SizedBox(height: 8),
                const Center(child: Text('Superfit v1.0', style: TextStyle(color: Colors.grey, fontSize: 12))),
              ],
            ),
    );
  }
}
