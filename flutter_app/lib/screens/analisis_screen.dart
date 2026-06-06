import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class AnalisisScreen extends StatefulWidget {
  const AnalisisScreen({super.key});

  @override
  State<AnalisisScreen> createState() => _AnalisisScreenState();
}

class _AnalisisScreenState extends State<AnalisisScreen> {
  bool _imagenSeleccionada = false;
  bool _analizando         = false;
  bool _resultadoListo     = false;
  bool _mostrandoTips      = false;
  Uint8List? _imagenBytes;
  String _resultadoPatologia = '';
  double _confianza          = 0.0;
  String _recomendacion      = '';
  Map<String, dynamic> _probabilidades = {};
  Color _resultadoColor = Colors.green;

  int get _pasoActual => _resultadoListo ? 2 : (_imagenSeleccionada ? 1 : 0);

  static const String _baseUrl =
      'https://cafedetect-grupo05-production.up.railway.app/api/auth';

  // ── Colores para las 5 clases reales del modelo ──────────────────────────
  Color _getColor(String patologia) {
    switch (patologia) {
      case 'Hoja sana':        return Colors.green;
      case 'Roya del café':    return Colors.red;
      case 'Cercosporiosis':   return Colors.orange;
      case 'Minador de hojas': return Colors.deepOrange;
      case 'Phoma':            return Colors.brown;
      default:                 return Colors.orange;
    }
  }

  IconData _getIcon(String patologia) {
    switch (patologia) {
      case 'Hoja sana':        return Icons.eco;
      case 'Roya del café':    return Icons.warning_amber_rounded;
      case 'Minador de hojas': return Icons.pest_control;
      default:                 return Icons.bug_report_outlined;
    }
  }

  // Urgencia según patología (para agricultores)
  _Urgencia _getUrgencia(String patologia, double confianza) {
    if (patologia == 'Hoja sana') {
      return _Urgencia('Sin riesgo', Icons.check_circle, Colors.green, 'Continúa con el mantenimiento preventivo del cultivo.');
    }
    if (confianza < 0.65) {
      return _Urgencia('Resultado incierto', Icons.help_outline, Colors.grey, 'La confianza es baja. Toma otra foto con mejor iluminación.');
    }
    switch (patologia) {
      case 'Roya del café':
        return _Urgencia('¡Acción inmediata!', Icons.emergency, Colors.red, 'Aplica fungicidas en las próximas 24-48 horas para evitar propagación.');
      case 'Cercosporiosis':
        return _Urgencia('Atención pronto', Icons.warning_amber_rounded, Colors.orange, 'Trata el cultivo esta semana. Puede empeorar con la humedad.');
      case 'Minador de hojas':
        return _Urgencia('Atención pronto', Icons.warning_amber_rounded, Colors.deepOrange, 'Aplica insecticida esta semana antes de que la plaga se extienda.');
      case 'Phoma':
        return _Urgencia('Monitorear', Icons.visibility, Colors.brown, 'Mejora el drenaje y revisa el cultivo en los próximos días.');
      default:
        return _Urgencia('Monitorear', Icons.visibility, Colors.orange, 'Consulta a un especialista si los síntomas persisten.');
    }
  }

  // ── Selección de imagen ───────────────────────────────────────────────────
  Future<void> _seleccionarDesdeGaleria() async {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    await input.onChange.first;
    if (input.files!.isEmpty) return;
    await _procesarArchivo(input.files![0]);
  }

  Future<void> _tomarFoto() async {
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..setAttribute('capture', 'environment'); // abre cámara en móvil
    input.click();
    await input.onChange.first;
    if (input.files!.isEmpty) return;
    await _procesarArchivo(input.files![0]);
  }

  Future<void> _procesarArchivo(html.File file) async {
    final reader = html.FileReader()..readAsArrayBuffer(file);
    await reader.onLoad.first;
    setState(() {
      _imagenBytes        = reader.result as Uint8List;
      _imagenSeleccionada = true;
      _resultadoListo     = false;
      _mostrandoTips      = false;
    });
  }

  // ── Análisis ─────────────────────────────────────────────────────────────
  Future<void> _analizarImagen() async {
    if (_imagenBytes == null) return;
    setState(() => _analizando = true);

    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/clasificar/'));
      request.files.add(http.MultipartFile.fromBytes(
        'image', _imagenBytes!, filename: 'hoja.jpg'));

      final response = await request.send().timeout(const Duration(seconds: 30));
      final body     = await response.stream.bytesToString();
      final data     = jsonDecode(body);

      if (response.statusCode == 200) {
        setState(() {
          _analizando         = false;
          _resultadoListo     = true;
          _resultadoPatologia = data['prediccion'];
          _confianza          = data['confianza'] / 100.0;
          _recomendacion      = data['recomendacion'];
          _probabilidades     = data['probabilidades'];
          _resultadoColor     = _getColor(data['prediccion']);
        });
      } else {
        _mostrarError(data['error'] ?? 'Error desconocido');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Sin conexión. Verifica tu red e intenta de nuevo.'),
          backgroundColor: Colors.red.shade700,
          action: SnackBarAction(
            label: 'Reintentar',
            textColor: Colors.white,
            onPressed: _analizarImagen,
          ),
        ));
      }
    } finally {
      if (_analizando && mounted) setState(() => _analizando = false);
    }
  }

  void _mostrarError(String msg) {
    setState(() => _analizando = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $msg'), backgroundColor: Colors.red.shade700),
      );
    }
  }

  void _reiniciar() => setState(() {
    _imagenSeleccionada = false;
    _resultadoListo     = false;
    _analizando         = false;
    _imagenBytes        = null;
    _mostrandoTips      = false;
  });

  // ── Tips de cómo tomar buena foto ────────────────────────────────────────
  void _mostrarTips() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Row(children: [
            Icon(Icons.tips_and_updates, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text('Consejos para mejor resultado',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20))),
          ]),
          const SizedBox(height: 16),
          ...[
            ('📏', 'Distancia', 'Ubica la hoja a 15–25 cm de la cámara. Ni muy lejos ni muy cerca.'),
            ('☀️', 'Iluminación', 'Fotografía a la luz del día. Evita sombras fuertes o luz solar directa sobre la hoja.'),
            ('🍃', 'Una sola hoja', 'Pon una hoja a la vez. Que ocupe la mayor parte de la foto.'),
            ('🔍', 'Enfoca el envés', 'Si sospechas Roya, incluye el envés (parte de abajo) de la hoja donde aparece el polvo anaranjado.'),
            ('📷', 'Sin movimiento', 'Apoya el teléfono o mantén la mano firme para que la imagen no salga borrosa.'),
          ].map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.$1, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.$2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(t.$3, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4)),
              ])),
            ]),
          )),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Entendido'),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Analizar hoja',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          // Tips siempre visible
          Tooltip(
            message: 'Consejos para tomar una buena foto',
            child: IconButton(
              icon: const Icon(Icons.tips_and_updates_outlined, color: Colors.white),
              onPressed: _mostrarTips,
            ),
          ),
          if (_imagenSeleccionada)
            Tooltip(
              message: 'Reiniciar análisis',
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _reiniciar,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador de pasos
            _StepIndicator(pasoActual: _pasoActual),
            const SizedBox(height: 16),

            // ── Área de imagen ──────────────────────────────────────────────
            Container(
              height: 230,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _imagenSeleccionada ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                  width: _imagenSeleccionada ? 2 : 1,
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
              ),
              child: _imagenSeleccionada && _imagenBytes != null
                  ? Stack(alignment: Alignment.center, children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: Image.memory(_imagenBytes!,
                            width: double.infinity, height: double.infinity, fit: BoxFit.contain),
                      ),
                      if (_analizando)
                        Container(
                          constraints: const BoxConstraints(minHeight: 230, maxHeight: 400),
                          decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(17)),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 14),
                              Text('Analizando con IA...',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('Esto puede tomar unos segundos',
                                  style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                    ])
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text('Selecciona o toma una foto\nde la hoja de café',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14,
                                color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        TextButton.icon(
                          onPressed: _mostrarTips,
                          icon: Icon(Icons.tips_and_updates_outlined,
                              size: 16, color: Colors.green.shade700),
                          label: Text('Ver consejos para mejor foto',
                              style: TextStyle(fontSize: 12, color: Colors.green.shade700)),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 14),

            // ── Botones de captura ──────────────────────────────────────────
            if (!_imagenSeleccionada) ...[
              Row(children: [
                // Tomar foto (cámara)
                Expanded(
                  child: _CaptureButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Tomar foto',
                    sublabel: 'Abre la cámara',
                    color: const Color(0xFF2E7D32),
                    onTap: _tomarFoto,
                  ),
                ),
                const SizedBox(width: 12),
                // Seleccionar de galería
                Expanded(
                  child: _CaptureButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Galería',
                    sublabel: 'Seleccionar foto',
                    color: const Color(0xFF1565C0),
                    onTap: _seleccionarDesdeGaleria,
                  ),
                ),
              ]),
            ],

            // ── Botones post-selección ──────────────────────────────────────
            if (_imagenSeleccionada && !_resultadoListo) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _analizando ? null : _analizarImagen,
                  icon: _analizando
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.biotech),
                  label: Text(
                    _analizando ? 'Analizando con IA...' : 'ANALIZAR IMAGEN',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF2E7D32).withOpacity(0.6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _analizando ? null : _tomarFoto,
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text('Nueva foto'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _analizando ? null : _seleccionarDesdeGaleria,
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: const Text('Cambiar foto'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ]),
            ],

            // ── RESULTADO ───────────────────────────────────────────────────
            if (_resultadoListo) ...[
              const SizedBox(height: 16),

              // Alerta de baja confianza
              if (_confianza < 0.65) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade400, width: 1.5),
                  ),
                  child: Row(children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Confianza baja (${(_confianza * 100).toStringAsFixed(0)}%). '
                        'Toma otra foto con mejor iluminación para un resultado más preciso.',
                        style: TextStyle(fontSize: 12, color: Colors.amber.shade900, height: 1.4),
                      ),
                    ),
                  ]),
                ),
              ],

              // Tarjeta resultado principal
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _resultadoColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _resultadoColor.withOpacity(0.4), width: 1.5),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(_getIcon(_resultadoPatologia), color: _resultadoColor, size: 22),
                    const SizedBox(width: 8),
                    const Text('Resultado del análisis IA',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ]),
                  const SizedBox(height: 12),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Text(_resultadoPatologia,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                              color: _resultadoColor)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _resultadoColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _resultadoColor == Colors.green ? 'SANA' : 'DETECTADA',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                            color: _resultadoColor),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Text('Confianza del modelo: ',
                        style: TextStyle(color: Colors.black54, fontSize: 13)),
                    Text('${(_confianza * 100).toStringAsFixed(1)}%',
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
              const SizedBox(height: 12),

              // ── Indicador de urgencia ─────────────────────────────────────
              Builder(builder: (_) {
                final urg = _getUrgencia(_resultadoPatologia, _confianza);
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: urg.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: urg.color.withOpacity(0.35)),
                  ),
                  child: Row(children: [
                    Icon(urg.icono, color: urg.color, size: 28),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(urg.titulo,
                          style: TextStyle(fontWeight: FontWeight.bold,
                              color: urg.color, fontSize: 14)),
                      const SizedBox(height: 3),
                      Text(urg.descripcion,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4)),
                    ])),
                  ]),
                );
              }),
              const SizedBox(height: 12),

              // Probabilidades
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Distribución de probabilidades',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Confianza del modelo por clase',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  const SizedBox(height: 14),
                  ..._probabilidades.entries
                      .toList()
                      .sorted((a, b) => (b.value as double).compareTo(a.value as double))
                      .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Row(children: [
                              Icon(_getIcon(e.key), size: 14, color: _getColor(e.key)),
                              const SizedBox(width: 6),
                              Text(e.key, style: const TextStyle(fontSize: 12)),
                            ]),
                            Text('${((e.value as double) * 100).toStringAsFixed(1)}%',
                                style: TextStyle(fontWeight: FontWeight.bold,
                                    color: _getColor(e.key))),
                          ]),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: e.value as double,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(_getColor(e.key)),
                              minHeight: 7,
                            ),
                          ),
                        ]),
                      )),
                ]),
              ),
              const SizedBox(height: 12),

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
                    Text('Recomendación',
                        style: TextStyle(fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800)),
                  ]),
                  const SizedBox(height: 8),
                  Text(_recomendacion, style: const TextStyle(fontSize: 13, height: 1.5)),
                ]),
              ),
              const SizedBox(height: 16),

              // Acciones post-resultado
              Row(children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _tomarFoto,
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text('Nueva foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _reiniciar,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reiniciar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Modelo de urgencia ────────────────────────────────────────────────────────
class _Urgencia {
  final String titulo, descripcion;
  final IconData icono;
  final Color color;
  const _Urgencia(this.titulo, this.icono, this.color, this.descripcion);
}

// ── Botón de captura (cámara / galería) ───────────────────────────────────────
class _CaptureButton extends StatelessWidget {
  final IconData icon;
  final String label, sublabel;
  final Color color;
  final VoidCallback onTap;
  const _CaptureButton({
    required this.icon, required this.label, required this.sublabel,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: color.withOpacity(0.35),
                blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white,
                fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(sublabel, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ]),
        ),
      ),
    );
  }
}

// ── Indicador de pasos ────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int pasoActual;
  const _StepIndicator({required this.pasoActual});

  @override
  Widget build(BuildContext context) {
    final steps = ['Capturar', 'Analizar', 'Resultado'];
    return Row(
      children: List.generate(steps.length, (i) {
        final isActive = i == pasoActual;
        final isDone   = i < pasoActual;
        return Expanded(
          child: Row(children: [
            Column(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: isDone || isActive ? const Color(0xFF2E7D32) : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text('${i + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.grey.shade500,
                            fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 4),
              Text(steps[i], style: TextStyle(
                fontSize: 10,
                color: isActive ? const Color(0xFF2E7D32) : Colors.grey.shade500,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
            ]),
            if (i < steps.length - 1)
              Expanded(child: Container(height: 2,
                  margin: const EdgeInsets.only(bottom: 18),
                  color: isDone || isActive ? const Color(0xFF2E7D32) : Colors.grey.shade300)),
          ]),
        );
      }),
    );
  }
}

// ── Extensión sort ────────────────────────────────────────────────────────────
extension _SortedList<T> on List<T> {
  List<T> sorted(int Function(T, T) compare) => [...this]..sort(compare);
}
