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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Historial de análisis', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.filter_list, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Resumen
          Container(
            color: const Color(0xFF2E7D32),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(children: [
              _SummaryChip(label: 'Total', value: '24', color: Colors.white),
              const SizedBox(width: 10),
              _SummaryChip(label: 'Enfermos', value: '7', color: Colors.red.shade300),
              const SizedBox(width: 10),
              _SummaryChip(label: 'Sanos', value: '17', color: Colors.green.shade300),
            ]),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _historial.length,
              itemBuilder: (context, index) {
                final item = _historial[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: (item['color'] as Color).withOpacity(0.15),
                      child: Icon(
                        item['estado'] == 'Sano' ? Icons.eco : Icons.bug_report,
                        color: item['color'] as Color,
                      ),
                    ),
                    title: Text(item['patologia'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: 4),
                      Text('${item['fecha']} — ${item['hora']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(item['estado'], style: TextStyle(fontSize: 11, color: item['color'] as Color, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text('Confianza: ${item['confianza']}%', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ]),
                    ]),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {},
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

class _SummaryChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryChip({required this.label, required this.value, required this.color});

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
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ),
    );
  }
}
