import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      DashboardTab(user: widget.user, onIrAAnalizar: () => _goToTab(1),
          onIrAEnfermedades: () => _goToTab(3)),
      const AnalisisScreen(),
      const HistorialScreen(),
      const EnfermedadesScreen(),
      PerfilScreen(user: widget.user),
    ];
  }

  void _goToTab(int i) => setState(() => _selectedIndex = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _goToTab,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF2E7D32).withOpacity(0.15),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined),      selectedIcon: Icon(Icons.home,          color: Color(0xFF2E7D32)), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.camera_alt_outlined), selectedIcon: Icon(Icons.camera_alt,    color: Color(0xFF2E7D32)), label: 'Analizar'),
          NavigationDestination(icon: Icon(Icons.history_outlined),    selectedIcon: Icon(Icons.history,       color: Color(0xFF2E7D32)), label: 'Historial'),
          NavigationDestination(icon: Icon(Icons.local_florist_outlined), selectedIcon: Icon(Icons.local_florist, color: Color(0xFF2E7D32)), label: 'Enfermedades'),
          NavigationDestination(icon: Icon(Icons.person_outline),      selectedIcon: Icon(Icons.person,        color: Color(0xFF2E7D32)), label: 'Perfil'),
        ],
      ),
    );
  }
}

// ─── DASHBOARD ────────────────────────────────────────────────────────────────
class DashboardTab extends StatefulWidget {
  final UserModel user;
  final VoidCallback onIrAAnalizar;
  final VoidCallback onIrAEnfermedades;
  const DashboardTab({super.key, required this.user, required this.onIrAAnalizar,
      required this.onIrAEnfermedades});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final _service = AuthService();
  Map<String, int> _stats = {'total': 0, 'sanos': 0, 'enfermos': 0};
  bool _cargandoStats = true;

  @override
  void initState() {
    super.initState();
    _cargarStats();
    _mostrarOnboardingSiNecesario();
  }

  Future<void> _mostrarOnboardingSiNecesario() async {
    final prefs = await SharedPreferences.getInstance();
    final yaVisto = prefs.getBool('onboarding_visto') ?? false;
    if (!yaVisto && mounted) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) _mostrarOnboarding();
      await prefs.setBool('onboarding_visto', true);
    }
  }

  void _mostrarOnboarding() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.eco_rounded, color: Color(0xFF2E7D32), size: 48),
            ),
            const SizedBox(height: 16),
            const Text('¡Bienvenido a CaféDetect!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20))),
            const SizedBox(height: 8),
            Text('Tu asistente inteligente para detectar enfermedades en hojas de café.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5)),
            const SizedBox(height: 20),
            ...[
              (Icons.camera_alt_rounded, const Color(0xFF2E7D32),
                  'Toma o sube una foto', 'de una hoja de café'),
              (Icons.biotech, const Color(0xFF1565C0),
                  'La IA analiza la imagen', 'y detecta la patología'),
              (Icons.medical_services_outlined, const Color(0xFFF57F17),
                  'Recibe una recomendación', 'de tratamiento inmediata'),
            ].map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: t.$2.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(t.$1, color: t.$2, size: 22),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.$3, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(t.$4, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ]),
              ]),
            )),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); widget.onIrAAnalizar(); },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('¡Empezar a analizar!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Explorar primero',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _cargarStats() async {
    final stats = await _service.getStats();
    if (mounted) setState(() { _stats = stats; _cargandoStats = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('CaféDetect',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          Tooltip(
            message: 'Notificaciones',
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No tienes notificaciones nuevas'),
                    duration: Duration(seconds: 2)),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF2E7D32),
        onRefresh: _cargarStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.3),
                    blurRadius: 12, offset: const Offset(0, 5),
                  )],
                ),
                child: Row(children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      widget.user.fullName.isNotEmpty
                          ? widget.user.fullName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('¡Hola de nuevo!',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text(widget.user.fullName,
                        style: const TextStyle(color: Colors.white, fontSize: 19,
                            fontWeight: FontWeight.bold)),
                    const Text('Sistema de detección de patologías',
                        style: TextStyle(color: Colors.white60, fontSize: 12)),
                  ])),
                ]),
              ),
              const SizedBox(height: 20),

              // Stats reales
              const Text('Resumen de actividad',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20))),
              const SizedBox(height: 12),
              _cargandoStats
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                  : Row(children: [
                      _StatCard(label: 'Análisis\nrealizados', value: '${_stats['total']}',
                          icon: Icons.analytics_outlined, color: const Color(0xFF2E7D32),
                          tooltip: 'Total de hojas analizadas'),
                      const SizedBox(width: 12),
                      _StatCard(label: 'Patologías\ndetectadas', value: '${_stats['enfermos']}',
                          icon: Icons.bug_report_outlined, color: const Color(0xFFF57F17),
                          tooltip: 'Hojas con enfermedad detectada'),
                      const SizedBox(width: 12),
                      _StatCard(label: 'Hojas\nsanas', value: '${_stats['sanos']}',
                          icon: Icons.eco_outlined, color: const Color(0xFF0277BD),
                          tooltip: 'Hojas clasificadas como sanas'),
                    ]),
              const SizedBox(height: 20),

              // CTA principal
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: widget.onIrAAnalizar,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
                    ),
                    child: Column(children: [
                      const Icon(Icons.camera_alt_rounded, size: 52, color: Color(0xFF2E7D32)),
                      const SizedBox(height: 12),
                      const Text('Analizar hoja de café',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20))),
                      const SizedBox(height: 6),
                      Text('Sube una foto para detectar patologías automáticamente',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: widget.onIrAAnalizar,
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: const Text('Iniciar análisis',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Patologías frecuentes del modelo
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Patologías detectables',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20))),
                TextButton(
                  onPressed: widget.onIrAEnfermedades,
                  child: const Text('Ver catálogo',
                      style: TextStyle(color: Color(0xFF2E7D32), fontSize: 13)),
                ),
              ]),
              const SizedBox(height: 10),
              _PathologyCard(nombre: 'Roya del café',    nivel: 'Alto riesgo',      color: Colors.red,        icon: Icons.warning_amber_rounded, porcentaje: 0.75),
              const SizedBox(height: 8),
              _PathologyCard(nombre: 'Cercosporiosis',   nivel: 'Riesgo moderado',  color: Colors.orange,     icon: Icons.warning_outlined,      porcentaje: 0.45),
              const SizedBox(height: 8),
              _PathologyCard(nombre: 'Minador de hojas', nivel: 'Riesgo moderado',  color: Colors.deepOrange, icon: Icons.pest_control,          porcentaje: 0.40),
              const SizedBox(height: 8),
              _PathologyCard(nombre: 'Phoma',            nivel: 'Bajo riesgo',      color: Colors.brown,      icon: Icons.water_drop_outlined,   porcentaje: 0.2),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, tooltip;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon,
      required this.color, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tooltip(
        message: tooltip,
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
            Text(label, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ]),
        ),
      ),
    );
  }
}

class _PathologyCard extends StatelessWidget {
  final String nombre, nivel;
  final Color color;
  final IconData icon;
  final double porcentaje;
  const _PathologyCard({required this.nombre, required this.nivel, required this.color,
      required this.icon, required this.porcentaje});

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
        Text('${(porcentaje * 100).toInt()}%',
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }
}
