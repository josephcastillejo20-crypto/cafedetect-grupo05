import 'package:flutter/material.dart';

/// Modelo para un análisis guardado en el historial
class AnalisisModel {
  final int id;
  final String patologia;
  final double confianza;
  final String recomendacion;
  final String fecha;
  final String hora;
  final String estado;

  AnalisisModel({
    required this.id,
    required this.patologia,
    required this.confianza,
    required this.recomendacion,
    required this.fecha,
    required this.hora,
    required this.estado,
  });

  bool get esSano => estado == 'Sano';

  Color get color {
    if (esSano) return Colors.green;
    switch (patologia) {
      case 'Roya del café':
        return Colors.red;
      case 'Cercosporiosis':
        return Colors.orange;
      case 'Minador de hojas':
        return Colors.deepOrange;
      case 'Phoma':
        return Colors.brown;
      default:
        return Colors.orange;
    }
  }

  factory AnalisisModel.fromJson(Map<String, dynamic> json) {
    return AnalisisModel(
      id:           json['id'] as int,
      patologia:    json['patologia'] as String,
      confianza:    (json['confianza'] as num).toDouble(),
      recomendacion: json['recomendacion'] as String,
      fecha:        json['fecha'] as String,
      hora:         json['hora'] as String,
      estado:       json['estado'] as String,
    );
  }
}
