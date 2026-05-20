import 'package:flutter/material.dart';

class EnfermedadesScreen extends StatefulWidget {
  const EnfermedadesScreen({super.key});

  @override
  State<EnfermedadesScreen> createState() => _EnfermedadesScreenState();
}

class _EnfermedadesScreenState extends State<EnfermedadesScreen> {
  String _busqueda = '';

  final List<Map<String, dynamic>> _enfermedades = [
    {
      'nombre': 'Roya del café',
      'cientifico': 'Hemileia vastatrix',
      'nivel': 'Alto riesgo',
      'color': Colors.red,
      'icono': Icons.warning_amber_rounded,
      'descripcion': 'Es la enfermedad más devastadora del café. Produce pústulas anaranjadas en el envés de las hojas que liberan esporas. Causa defoliación severa y pérdidas importantes en la cosecha.',
      'sintomas': ['Manchas amarillas en el haz de la hoja', 'Polvo anaranjado en el envés', 'Defoliación prematura', 'Ramas desnudas'],
      'tratamiento': 'Aplicar fungicidas cúpricos o triazoles. Podar ramas afectadas y mejorar ventilación del cultivo.',
    },
    {
      'nombre': 'Cercosporiosis',
      'cientifico': 'Cercospora coffeicola',
      'nivel': 'Riesgo moderado',
      'color': Colors.orange,
      'icono': Icons.warning_outlined,
      'descripcion': 'Afecta principalmente hojas y frutos del café. Se presenta con mayor frecuencia en plantas con deficiencias nutricionales o sometidas a estrés hídrico.',
      'sintomas': ['Manchas circulares con centro gris', 'Halo amarillo alrededor', 'Caída de hojas jóvenes', 'Manchas en el fruto'],
      'tratamiento': 'Mejorar nutrición del cultivo, especialmente potasio. Fungicidas preventivos y control de humedad.',
    },
    {
      'nombre': 'Antracnosis',
      'cientifico': 'Colletotrichum gloeosporioides',
      'nivel': 'Bajo riesgo',
      'color': Colors.amber,
      'icono': Icons.info_outline,
      'descripcion': 'Enfermedad fúngica que ataca múltiples partes de la planta. Se desarrolla en condiciones de alta humedad y temperatura moderada.',
      'sintomas': ['Lesiones oscuras en hojas', 'Manchas hundidas en frutos', 'Muerte regresiva de ramas', 'Frutos momificados'],
      'tratamiento': 'Eliminar material vegetal infectado. Aplicar fungicidas con mancozeb o clorotalonil.',
    },
    {
      'nombre': 'Mancha de hierro',
      'cientifico': 'Cercospora coffeicola (variante)',
      'nivel': 'Bajo riesgo',
      'color': Colors.brown,
      'icono': Icons.circle_outlined,
      'descripcion': 'Produce manchas con apariencia de óxido en las hojas. Asociada generalmente a deficiencias de micronutrientes en suelo.',
      'sintomas': ['Manchas rojizas o marrones', 'Apariencia de herrumbre', 'Necrosis en bordes', 'Hojas amarillentas'],
      'tratamiento': 'Análisis de suelo y corrección nutricional. Fungicidas de amplio espectro como preventivo.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtradas = _enfermedades.where((e) =>
        e['nombre'].toString().toLowerCase().contains(_busqueda.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Catálogo de patologías', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: Column(children: [
        // Buscador
        Container(
          color: const Color(0xFF2E7D32),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextField(
            onChanged: (v) => setState(() => _busqueda = v),
            decoration: InputDecoration(
              hintText: 'Buscar patología...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: filtradas.length,
            itemBuilder: (_, i) {
              final e = filtradas[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  leading: CircleAvatar(
                    backgroundColor: (e['color'] as Color).withOpacity(0.15),
                    child: Icon(e['icono'] as IconData, color: e['color'] as Color),
                  ),
                  title: Text(e['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e['cientifico'], style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (e['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(e['nivel'], style: TextStyle(fontSize: 11, color: e['color'] as Color, fontWeight: FontWeight.bold)),
                    ),
                  ]),
                  children: [
                    Text(e['descripcion'], style: const TextStyle(fontSize: 13, height: 1.5)),
                    const SizedBox(height: 12),
                    const Text('Síntomas:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    ...(e['sintomas'] as List<String>).map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(children: [
                        Icon(Icons.circle, size: 7, color: e['color'] as Color),
                        const SizedBox(width: 8),
                        Text(s, style: const TextStyle(fontSize: 13)),
                      ]),
                    )),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Row(children: [
                          Icon(Icons.medical_services_outlined, size: 16, color: Color(0xFF2E7D32)),
                          SizedBox(width: 6),
                          Text('Tratamiento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2E7D32))),
                        ]),
                        const SizedBox(height: 6),
                        Text(e['tratamiento'], style: const TextStyle(fontSize: 13, height: 1.4)),
                      ]),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
