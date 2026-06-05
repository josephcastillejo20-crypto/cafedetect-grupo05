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
  bool _analizando = false;
  bool _resultadoListo = false;
  Uint8List? _imagenBytes;
  String _resultadoPatologia = '';
  double _confianza = 0.0;
  String _recomendacion = '';
  Map<String, dynamic> _probabilidades = {};
  Color _resultadoColor = Colors.green;

  static const String baseUrl =
      'https://cafedetect-grupo05-production.up.railway.app/api/auth';

  Color _getColor(String patologia) {
    if (patologia == 'Hoja sana') return Colors.green;
    if (patologia == 'Roya del café') return Colors.red;
    return Colors.orange;
  }

  Future<void> _seleccionarImagen() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();

    await input.onChange.first;

    if (input.files!.isEmpty) return;

    final file = input.files![0];
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);

    await reader.onLoad.first;

    final bytes = reader.result as Uint8List;
    setState(() {
      _imagenBytes = bytes;
      _imagenSeleccionada = true;
      _resultadoListo = false;
    });
  }

  Future<void> _analizarImagen() async {
    if (_imagenBytes == null) return;
    setState(() => _analizando = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/clasificar/'),
      );
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        _imagenBytes!,
        filename: 'hoja.jpg',
      ));

      final response = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);

      if (response.statusCode == 200) {
        setState(() {
          _analizando = false;
          _resultadoListo = true;
          _resultadoPatologia = data['prediccion'];
          _confianza = data['confianza'] / 100.0;
          _recomendacion = data['recomendacion'];
          _probabilidades = data['probabilidades'];
          _resultadoColor = _getColor(data['prediccion']);
        });
      } else {
        setState(() => _analizando = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${data['error'] ?? 'desconocido'}')),
          );
        }
      }
    } catch (e) {
      setState(() => _analizando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: $e')),
        );
      }
    }
  }

  void _reiniciar() {
    setState(() {
      _imagenSeleccionada = false;
      _resultadoListo = false;
      _analizando = false;
      _imagenBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Analizar Hoja',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          if (_imagenSeleccionada)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _reiniciar,
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
                  color: _imagenSeleccionada
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade300,
                  width: _imagenSeleccionada ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06), blurRadius: 10)
                ],
              ),
              child: _imagenSeleccionada && _imagenBytes != null
                  ? Stack(alignment: Alignment.center, children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                       child: Image.memory(
                           _imagenBytes!,
                           width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (_analizando)
                       Container(
                        constraints: const BoxConstraints(
                        minHeight: 220,
                        maxHeight: 400,
                        ),
                      decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 14),
                              Text('Analizando con IA...',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ])
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text('Selecciona una imagen de hoja de café',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade600)),
                        const SizedBox(height: 4),
                        Text('JPG, PNG',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade400)),
                      ],
                    ),
            ),
            const SizedBox(height: 14),

            // Botón selección imagen
            if (!_imagenSeleccionada)
              _ActionButton(
                icon: Icons.photo_library_outlined,
                label: 'Seleccionar imagen',
                color: const Color(0xFF2E7D32),
                onTap: _seleccionarImagen,
              ),

            // Botón analizar
            if (_imagenSeleccionada && !_resultadoListo) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _analizando ? null : _analizarImagen,
                  icon: _analizando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.biotech),
                  label: Text(
                      _analizando
                          ? 'Analizando con IA...'
                          : 'ANALIZAR IMAGEN',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],

            // RESULTADO
            if (_resultadoListo) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _resultadoColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: _resultadoColor.withOpacity(0.4), width: 1.5),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.biotech,
                            color: _resultadoColor, size: 22),
                        const SizedBox(width: 8),
                        const Text('Resultado del análisis IA',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ]),
                      const SizedBox(height: 12),
                      Text(_resultadoPatologia,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _resultadoColor)),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Text('Confianza: ',
                            style: TextStyle(color: Colors.black54)),
                        Text('${(_confianza * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _resultadoColor)),
                      ]),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _confianza,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              _resultadoColor),
                          minHeight: 8,
                        ),
                      ),
                    ]),
              ),
              const SizedBox(height: 14),

              // Probabilidades
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8)
                  ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Probabilidades por clase',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 14),
                      ..._probabilidades.entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(e.key,
                                            style: const TextStyle(
                                                fontSize: 12)),
                                        Text(
                                            '${((e.value as double) * 100).toStringAsFixed(1)}%',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: _getColor(e.key))),
                                      ]),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: e.value as double,
                                      backgroundColor:
                                          Colors.grey.shade200,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              _getColor(e.key)),
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
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.lightbulb_outline,
                            color: Colors.amber.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text('Recomendación',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800)),
                      ]),
                      const SizedBox(height: 8),
                      Text(_recomendacion,
                          style: const TextStyle(
                              fontSize: 13, height: 1.5)),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ]),
      ),
    );
  }
}