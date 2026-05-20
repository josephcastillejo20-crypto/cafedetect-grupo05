import 'package:flutter/material.dart';

/// Pantalla de análisis de hoja de café
class AnalisisScreen extends StatefulWidget {
  const AnalisisScreen({super.key});

  @override
  State<AnalisisScreen> createState() => _AnalisisScreenState();
}

class _AnalisisScreenState extends State<AnalisisScreen> {
  bool _imagenSeleccionada = false;
  bool _analizando = false;
  bool _resultadoListo = false;
  String _resultadoPatologia = '';
  double _confianza = 0.0;
  Color _resultadoColor = Colors.green;

  final List<Map<String, dynamic>> _patologias = [
    {'nombre': 'Roya del café (Hemileia vastatrix)', 'confianza': 0.87, 'color': Colors.red.shade700, 'nivel': 'ALTO RIESGO'},
    {'nombre': 'Cercosporiosis', 'confianza': 0.09, 'color': Colors.orange, 'nivel': ''},
    {'nombre': 'Antracnosis', 'confianza': 0.04, 'color': Colors.green, 'nivel': ''},
  ];

  void _simularSeleccionImagen() {
    setState(() {
      _imagenSeleccionada = true;
      _resultadoListo = false;
    });
  }

  Future<void> _simularAnalisis() async {
    setState(() => _analizando = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _analizando = false;
      _resultadoListo = true;
      _resultadoPatologia = 'Roya del café';
      _confianza = 0.87;
      _resultadoColor = Colors.red.shade700;
    });
  }

  void _reiniciar() {
    setState(() {
      _imagenSeleccionada = false;
      _resultadoListo = false;
      _analizando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Analizar Hoja', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          if (_imagenSeleccionada)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _reiniciar,
              tooltip: 'Reiniciar',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Área de imagen
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _imagenSeleccionada ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                  width: _imagenSeleccionada ? 2 : 1,
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
              ),
              child: _imagenSeleccionada
                  ? Stack(alignment: Alignment.center, children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: Container(
                          width: double.infinity,
                          color: Colors.green.shade50,
                          child: const Icon(Icons.eco, size: 100, color: Color(0xFF2E7D32)),
                        ),
                      ),
                      if (_analizando)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 14),
                              Text('Analizando...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ])
                  : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text('Selecciona una imagen', style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('JPG, PNG — máx 10MB', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                    ]),
            ),
            const SizedBox(height: 14),

            // Botones de selección
            if (!_imagenSeleccionada) ...[
              Row(children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Tomar foto',
                    color: const Color(0xFF2E7D32),
                    onTap: _simularSeleccionImagen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Galería',
                    color: const Color(0xFF0277BD),
                    onTap: _simularSeleccionImagen,
                  ),
                ),
              ]),
            ],

            // Botón analizar
            if (_imagenSeleccionada && !_resultadoListo) ...[
              const SizedBox(height: 6),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _analizando ? null : _simularAnalisis,
                  icon: _analizando
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.search),
                  label: Text(_analizando ? 'Procesando...' : 'ANALIZAR IMAGEN', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],

            // RESULTADO
            if (_resultadoListo) ...[
              const SizedBox(height: 16),
              // Resultado principal
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _resultadoColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _resultadoColor.withOpacity(0.4), width: 1.5),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.bug_report, color: _resultadoColor, size: 22),
                    const SizedBox(width: 8),
                    const Text('Resultado del análisis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ]),
                  const SizedBox(height: 12),
                  Text(_resultadoPatologia, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _resultadoColor)),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Text('Confianza: ', style: TextStyle(color: Colors.black54)),
                    Text('${(_confianza * 100).toStringAsFixed(0)}%',
                        style: TextStyle(fontWeight: FontWeight.bold, color: _resultadoColor)),
                  ]),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _confianza,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(_resultadoColor),
                      minHeight: 8,
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 14),

              // Distribución de probabilidades
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Distribución de probabilidades', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 14),
                  ..._patologias.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(p['nombre'], style: const TextStyle(fontSize: 12)),
                        Text('${(p['confianza'] * 100).toStringAsFixed(0)}%',
                            style: TextStyle(fontWeight: FontWeight.bold, color: p['color'])),
                      ]),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: p['confianza'],
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(p['color']),
                          minHeight: 7,
                        ),
                      ),
                    ]),
                  )),
                ]),
              ),
              const SizedBox(height: 14),

              // Recomendación
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.lightbulb_outline, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text('Recomendación', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
                  ]),
                  const SizedBox(height: 8),
                  const Text(
                    'Se detectó roya del café con alta probabilidad. Se recomienda aplicar fungicidas a base de cobre o triazoles y eliminar las hojas más afectadas. Consulte a un especialista fitosanitario.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _reiniciar,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Analizar otra hoja'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                  side: const BorderSide(color: Color(0xFF2E7D32)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
      ),
    );
  }
}
