import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'editar_perfil_screen.dart';
import 'cambiar_password_screen.dart';

class PerfilScreen extends StatefulWidget {
  final UserModel user;
  const PerfilScreen({super.key, required this.user});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _service = AuthService();
  late UserModel _user;
  Map<String, int> _stats = {'total': 0, 'sanos': 0, 'enfermos': 0};
  bool _cargandoStats = true;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _cargarStats();
  }

  Future<void> _cargarStats() async {
    final stats = await _service.getStats();
    if (mounted) setState(() { _stats = stats; _cargandoStats = false; });
  }

  Future<void> _irAEditarPerfil() async {
    final updatedUser = await Navigator.push<UserModel>(
      context,
      MaterialPageRoute(builder: (_) => EditarPerfilScreen(user: _user)),
    );
    if (updatedUser != null && mounted) {
      setState(() => _user = updatedUser);
    }
  }

  Future<void> _confirmarLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar tu sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await _service.logout();
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }
  }

  void _mostrarSobreApp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.eco, color: Color(0xFF2E7D32)),
          SizedBox(width: 8),
          Text('CaféDetect'),
        ]),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versión: 1.0.0'),
            SizedBox(height: 8),
            Text(
              'Aplicación de detección inteligente de patologías en hojas de café '
              'usando Inteligencia Artificial (CNN).',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            SizedBox(height: 8),
            Text('Patologías detectables:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            SizedBox(height: 4),
            Text('• Roya del café\n• Cercosporiosis\n• Minador de hojas\n• Phoma\n• Hoja sana',
                style: TextStyle(fontSize: 13, height: 1.6)),
            SizedBox(height: 8),
            Text('Desarrollado por el Grupo 05',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Curso: Interacción Hombre-Computador',
                style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Mi perfil',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          // Header
          Container(
            width: double.infinity,
            color: const Color(0xFF2E7D32),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(children: [
              Stack(alignment: Alignment.bottomRight, children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    _user.fullName.isNotEmpty ? _user.fullName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                GestureDetector(
                  onTap: _irAEditarPerfil,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2E7D32), width: 2),
                    ),
                    child: const Icon(Icons.edit, color: Color(0xFF2E7D32), size: 14),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Text(_user.fullName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text('@${_user.username}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              if (_user.email.isNotEmpty)
                Text(_user.email,
                    style: const TextStyle(color: Colors.white60, fontSize: 13)),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Stats reales
              const Text('Mi actividad',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20))),
              const SizedBox(height: 10),
              _cargandoStats
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(color: Color(0xFF2E7D32))))
                  : Row(children: [
                      _StatTile(value: '${_stats['total']}', label: 'Análisis',
                          icon: Icons.analytics_outlined, tooltip: 'Total de hojas analizadas'),
                      const SizedBox(width: 10),
                      _StatTile(value: '${_stats['enfermos']}', label: 'Patologías',
                          icon: Icons.bug_report_outlined, tooltip: 'Patologías encontradas'),
                      const SizedBox(width: 10),
                      _StatTile(value: '${_stats['sanos']}', label: 'Sanas',
                          icon: Icons.eco_outlined, tooltip: 'Hojas sanas'),
                    ]),
              const SizedBox(height: 20),

              // Configuración
              const Text('Configuración',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20))),
              const SizedBox(height: 10),
              _MenuCard(children: [
                _MenuItem(
                  icon: Icons.person_outline,
                  label: 'Editar perfil',
                  onTap: _irAEditarPerfil,
                ),
                _MenuItem(
                  icon: Icons.lock_outline,
                  label: 'Cambiar contraseña',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CambiarPasswordScreen())),
                ),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notificaciones',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notificaciones disponibles próximamente'),
                        duration: Duration(seconds: 2)),
                  ),
                ),
              ]),
              const SizedBox(height: 14),

              // Acerca de
              const Text('Acerca de',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20))),
              const SizedBox(height: 10),
              _MenuCard(children: [
                _MenuItem(
                  icon: Icons.info_outline,
                  label: 'Sobre la aplicación',
                  onTap: _mostrarSobreApp,
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  label: 'Ayuda y soporte',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ayuda disponible próximamente'),
                        duration: Duration(seconds: 2)),
                  ),
                ),
                _MenuItem(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Política de privacidad',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Política de privacidad próximamente'),
                        duration: Duration(seconds: 2)),
                  ),
                ),
              ]),
              const SizedBox(height: 14),

              Center(
                child: Text(
                  'CaféDetect v1.0 — Grupo 05\nCurso: Interacción Hombre-Computador',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500, height: 1.5),
                ),
              ),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _confirmarLogout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Cerrar sesión',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value, label, tooltip;
  final IconData icon;
  const _StatTile({required this.value, required this.label, required this.icon, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tooltip(
        message: tooltip,
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
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32))),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ]),
        ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
          title: Text(label, style: const TextStyle(fontSize: 14)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ),
      ),
    );
  }
}
