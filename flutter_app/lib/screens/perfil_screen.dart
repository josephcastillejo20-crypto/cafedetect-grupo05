import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class PerfilScreen extends StatelessWidget {
  final UserModel user;
  const PerfilScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Mi perfil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header perfil
            Container(
              width: double.infinity,
              color: const Color(0xFF2E7D32),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('@${user.username}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                if (user.email.isNotEmpty)
                  Text(user.email, style: const TextStyle(color: Colors.white60, fontSize: 13)),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estadísticas del usuario
                  const Text('Actividad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                  const SizedBox(height: 10),
                  Row(children: [
                    _StatTile(value: '24', label: 'Análisis', icon: Icons.analytics_outlined),
                    const SizedBox(width: 10),
                    _StatTile(value: '7', label: 'Patologías', icon: Icons.bug_report_outlined),
                    const SizedBox(width: 10),
                    _StatTile(value: '17', label: 'Sanas', icon: Icons.eco_outlined),
                  ]),
                  const SizedBox(height: 20),

                  // Opciones de menú
                  const Text('Configuración', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                  const SizedBox(height: 10),
                  _MenuCard(children: [
                    _MenuItem(icon: Icons.person_outline, label: 'Editar perfil', onTap: () {}),
                    _MenuItem(icon: Icons.lock_outline, label: 'Cambiar contraseña', onTap: () {}),
                    _MenuItem(icon: Icons.notifications_outlined, label: 'Notificaciones', onTap: () {}),
                  ]),
                  const SizedBox(height: 14),

                  const Text('Acerca de', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                  const SizedBox(height: 10),
                  _MenuCard(children: [
                    _MenuItem(icon: Icons.info_outline, label: 'Sobre la aplicación', onTap: () {}),
                    _MenuItem(icon: Icons.help_outline, label: 'Ayuda y soporte', onTap: () {}),
                    _MenuItem(icon: Icons.privacy_tip_outlined, label: 'Política de privacidad', onTap: () {}),
                  ]),
                  const SizedBox(height: 14),

                  // Versión
                  Center(
                    child: Text(
                      ' ',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Cerrar sesión
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await AuthService().logout();
                        if (context.mounted) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Cerrar sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _StatTile({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
        ),
        child: Column(children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 22),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ]),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}
