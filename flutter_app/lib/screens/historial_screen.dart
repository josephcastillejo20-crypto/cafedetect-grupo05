import 'package:flutter/material.dart';
import '../models/analisis_model.dart';
import '../services/auth_service.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final _service = AuthService();
  List<AnalisisModel> _historial = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    setState(() { _cargando = true; _error = null; });
    final data = await _service.getHistorial();
    if (mounted) {
      setState(() {
        _historial = data;
        _cargando  = false;
      });
    }
  }

  void _mostrarDetalle(AnalisisModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                CircleAvatar(
                  backgroundColor: item.color.withOpacity(0.15),
                  child: Icon(
                    item.esSano ? Icons.eco : Icons.bug_report,
                    color: item.color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.patologia,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('${item.fecha} — ${item.hora}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  ],
                )),
              ]),
              const SizedBox(height: 20),
              _detailRow('Estado', item.estado, item.color),
              const SizedBox(height: 10),
              _detailRow('Confianza del modelo', '${item.confianza.toStringAsFixed(1)}%', item.color),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: item.confianza / 100.0,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(item.color),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.lightbulb_outline, color: Colors.amber.shade700, size: 18),
                    const SizedBox(width: 6),
                    Text('Recomendación',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
                  ]),
                  const SizedBox(height: 8),
                  Text(item.recomendacion,
                      style: const TextStyle(fontSize: 13, height: 1.5)),
                ]),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, Color valueColor) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final total    = _historial.length;
    final sanos    = _historial.where((e) => e.esSano).length;
    final enfermos = total - sanos;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Historial de análisis',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          Tooltip(
            message: 'Actualizar',
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _cargarHistorial,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumen estadístico
          Container(
            color: const Color(0xFF2E7D32),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(children: [
              _SummaryChip(label: 'Total',    value: '$total',    color: Colors.white,          icon: Icons.analytics_outlined),
              const SizedBox(width: 10),
              _SummaryChip(label: 'Enfermos', value: '$enfermos', color: Colors.red.shade300,   icon: Icons.bug_report_outlined),
              const SizedBox(width: 10),
              _SummaryChip(label: 'Sanos',    value: '$sanos',    color: Colors.green.shade300, icon: Icons.eco_outlined),
            ]),
          ),

          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(color: Color(0xFF2E7D32)),
          SizedBox(height: 14),
          Text('Cargando historial...', style: TextStyle(color: Colors.grey)),
        ]),
      );
    }

    if (_historial.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.history_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Sin análisis aún',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
          const SizedBox(height: 8),
          Text(
            'Tus análisis de hojas aparecerán aquí\nuna vez que uses el analizador',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _cargarHistorial,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar'),
            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF2E7D32)),
          ),
        ]),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF2E7D32),
      onRefresh: _cargarHistorial,
      child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: _historial.length,
        itemBuilder: (context, i) {
          final item = _historial[i];
          return Semantics(
            label: '${item.patologia}, ${item.estado}, confianza ${item.confianza.toStringAsFixed(0)}%, ${item.fecha}',
            button: true,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _mostrarDetalle(item),
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: item.color.withOpacity(0.15),
                      child: Icon(
                        item.esSano ? Icons.eco : Icons.bug_report,
                        color: item.color,
                      ),
                    ),
                    title: Text(item.patologia,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: 4),
                      Text('${item.fecha} — ${item.hora}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(item.estado,
                              style: TextStyle(fontSize: 11, color: item.color, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text('Confianza: ${item.confianza.toStringAsFixed(1)}%',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ]),
                    ]),
                    trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _SummaryChip({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ),
    );
  }
}
