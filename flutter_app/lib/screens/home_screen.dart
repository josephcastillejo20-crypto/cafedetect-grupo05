import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'analisis_screen.dart';
import 'historial_screen.dart';
import 'enfermedades_screen.dart';
import 'perfil_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardTab(user: widget.user),
      const AnalisisScreen(),
      const HistorialScreen(),
      const EnfermedadesScreen(),
      PerfilScreen(user: widget.user),
    ];
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar tu sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService().logout();
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF2E7D32).withOpacity(0.15),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Color(0xFF2E7D32)), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.camera_alt_outlined), selectedIcon: Icon(Icons.camera_alt, color: Color(0xFF2E7D32)), label: 'Analizar'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history, color: Color(0xFF2E7D32)), label: 'Historial'),
          NavigationDestination(icon: Icon(Icons.local_florist_outlined), selectedIcon: Icon(Icons.local_florist, color: Color(0xFF2E7D32)), label: 'Enfermedades'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: Color(0xFF2E7D32)), label: 'Perfil'),
        ],
      ),
    );
  }
}

// ─── TAB DASHBOARD ────────────────────────────────────────────────────────────
class DashboardTab extends StatelessWidget {
  final UserModel user;
  const DashboardTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('CaféDetect', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bienvenida
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: const Color(0xFF2E7D32).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('¡Hola de nuevo!', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text(user.fullName, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
                      const Text('Sistema de detección de patologías', style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Estadísticas rápidas
            const Text('Resumen', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(label: 'Análisis\nrealizados', value: '24', icon: Icons.analytics_outlined, color: const Color(0xFF2E7D32)),
                const SizedBox(width: 12),
                _StatCard(label: 'Patologías\ndetectadas', value: '7', icon: Icons.bug_report_outlined, color: const Color(0xFFF57F17)),
                const SizedBox(width: 12),
                _StatCard(label: 'Hojas\nsanas', value: '17', icon: Icons.eco_outlined, color: const Color(0xFF0277BD)),
              ],
            ),
            const SizedBox(height: 20),

            // Acción principal
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
                ),
                child: Column(children: [
                  const Icon(Icons.camera_alt_rounded, size: 52, color: Color(0xFF2E7D32)),
                  const SizedBox(height: 12),
                  const Text('Analizar hoja de café', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                  const SizedBox(height: 6),
                  Text('Toma o sube una foto para detectar\npatologías automáticamente',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Iniciar análisis', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 20),

            // Patologías comunes
            const Text('Patologías frecuentes', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
            const SizedBox(height: 12),
            _PathologyCard(nombre: 'Roya del café', nivel: 'Alto riesgo', color: Colors.red.shade700, icon: Icons.warning_amber_rounded, porcentaje: 0.75),
            const SizedBox(height: 8),
            _PathologyCard(nombre: 'Cercosporiosis', nivel: 'Riesgo moderado', color: Colors.orange.shade700, icon: Icons.warning_outlined, porcentaje: 0.45),
            const SizedBox(height: 8),
            _PathologyCard(nombre: 'Antracnosis', nivel: 'Bajo riesgo', color: Colors.green.shade700, icon: Icons.check_circle_outline, porcentaje: 0.2),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ]),
      ),
    );
  }
}

class _PathologyCard extends StatelessWidget {
  final String nombre, nivel;
  final Color color;
  final IconData icon;
  final double porcentaje;
  const _PathologyCard({required this.nombre, required this.nivel, required this.color, required this.icon, required this.porcentaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(nivel, style: TextStyle(fontSize: 12, color: color)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: porcentaje,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ])),
        const SizedBox(width: 10),
        Text('${(porcentaje * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }
}
