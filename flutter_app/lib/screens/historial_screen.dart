import 'package:flutter/material.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  final List<Map<String, dynamic>> _historial = const [
    {'fecha': '18 May 2025', 'hora': '10:32 AM', 'patologia': 'Roya del café', 'confianza': 87, 'estado': 'Enfermo', 'color': Colors.red},
    {'fecha': '15 May 2025', 'hora': '02:15 PM', 'patologia': 'Hoja sana', 'confianza': 95, 'estado': 'Sano', 'color': Colors.green},
    {'fecha': '12 May 2025', 'hora': '09:00 AM', 'patologia': 'Cercosporiosis', 'confianza': 73, 'estado': 'Enfermo', 'color': Colors.orange},
    {'fecha': '10 May 2025', 'hora': '04:45 PM', 'patologia': 'Antracnosis', 'confianza': 68, 'estado': 'Enfermo', 'color': Colors.orange},
    {'fecha': '07 May 2025', 'hora': '11:20 AM', 'patologia': 'Hoja sana', 'confianza': 92, 'estado': 'Sano', 'color': Colors.green},
    {'fecha': '03 May 2025', 'hora': '08:05 AM', 'patologia': 'Roya del café', 'confianza': 81, 'estado': 'Enfermo', 'color': Colors.red},
  ];

  void _mostrarDetalle(BuildContext context, Map<String, dynamic> item) {
    final color = item['color'] as Color;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(
                  item['estado'] == 'Sano' ? Icons.eco : Icons.bug_report,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    item['patologia'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${item['fecha']} — ${item['hora']}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ]),
              ),
            ]),
            const SizedBox(height: 20),
            _DetailRow(
              label: 'Estado',
              value: item['estado'],
              valueColor: color,
            ),
            const SizedBox(height: 10),
            _DetailRow(
              label: 'Confianza del modelo',
              value: '${item['confianza']}%',
              valueColor: color,
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (item['confianza'] as int) / 100.0,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSanos =
        _historial.where((e) => e['estado'] == 'Sano').length;
    final totalEnfermos = _historial.length - totalSanos;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text(
          'Historial de análisis',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          Tooltip(
            message: 'Filtrar por estado',
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Filtros disponibles próximamente'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
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
              _SummaryChip(
                label: 'Total',
                value: '${_historial.length}',
                color: Colors.white,
                icon: Icons.analytics_outlined,
              ),
              const SizedBox(width: 10),
              _SummaryChip(
                label: 'Enfermos',
                value: '$totalEnfermos',
                color: Colors.red.shade300,
                icon: Icons.bug_report_outlined,
              ),
              const SizedBox(width: 10),
              _SummaryChip(
                label: 'Sanos',
                value: '$totalSanos',
                color: Colors.green.shade300,
                icon: Icons.eco_outlined,
              ),
            ]),
          ),

          // Lista de análisis o estado vacío
          Expanded(
            child: _historial.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: _historial.length,
                    itemBuilder: (context, index) {
                      final item = _historial[index];
                      final color = item['color'] as Color;
                      return Semantics(
                        label:
                            '${item['patologia']}, ${item['estado']}, confianza ${item['confianza']}%, ${item['fecha']}',
                        button: true,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _mostrarDetalle(context, item),
                              borderRadius: BorderRadius.circular(14),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: color.withOpacity(0.15),
                                  child: Icon(
                                    item['estado'] == 'Sano'
                                        ? Icons.eco
                                        : Icons.bug_report,
                                    color: color,
                                  ),
                                ),
                                title: Text(
                                  item['patologia'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item['fecha']} — ${item['hora']}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          item['estado'],
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Confianza: ${item['confianza']}%',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600),
                                      ),
                                    ]),
                                  ],
                                ),
                                trailing: Icon(Icons.chevron_right,
                                    color: Colors.grey.shade400),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Sin análisis aún',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20)),
          ),
          const SizedBox(height: 8),
          Text(
            'Tus análisis de hojas aparecerán aquí\nuna vez que uses el analizador',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final Color valueColor;
  const _DetailRow(
      {required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor)),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _SummaryChip(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

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
          Text(
            value,
            style: TextStyle(
                color: color, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ),
    );
  }
}
