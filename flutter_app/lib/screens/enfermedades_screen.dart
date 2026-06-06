import 'package:flutter/material.dart';

class EnfermedadesScreen extends StatefulWidget {
  const EnfermedadesScreen({super.key});

  @override
  State<EnfermedadesScreen> createState() => _EnfermedadesScreenState();
}

class _EnfermedadesScreenState extends State<EnfermedadesScreen> {
  String _busqueda = '';

  // Catálogo alineado con las clases reales del modelo CNN
  final List<Map<String, dynamic>> _enfermedades = [
    {
      'nombre':      'Roya del café',
      'cientifico':  'Hemileia vastatrix',
      'nivel':       'Alto riesgo',
      'color':       Colors.red,
      'icono':       Icons.warning_amber_rounded,
      'descripcion': 'Es la enfermedad más devastadora del café a nivel mundial. Produce pústulas anaranjadas en el envés de las hojas que liberan esporas. Puede destruir hasta el 70% de la cosecha en un solo ciclo productivo si no se detecta a tiempo.',
      'sintomas': [
        'Manchas amarillas en el haz de la hoja',
        'Polvo anaranjado (esporas) en el envés',
        'Defoliación prematura severa',
        'Ramas completamente desnudas',
        'Reducción drástica de la producción',
      ],
      'tratamiento': 'Aplicar fungicidas cúpricos o triazoles de forma inmediata. Podar y destruir ramas afectadas. Mejorar la ventilación del cultivo y evitar el exceso de humedad.',
    },
    {
      'nombre':      'Cercosporiosis',
      'cientifico':  'Cercospora coffeicola',
      'nivel':       'Riesgo moderado',
      'color':       Colors.orange,
      'icono':       Icons.warning_outlined,
      'descripcion': 'Afecta principalmente hojas y frutos del café. Se presenta con mayor frecuencia en plantas con deficiencias nutricionales o sometidas a estrés hídrico. También conocida como "ojo de gallo" o "mancha de hierro".',
      'sintomas': [
        'Manchas circulares con centro gris o blanco',
        'Halo amarillo alrededor de la mancha',
        'Caída de hojas jóvenes y maduras',
        'Manchas en los frutos (brocas)',
        'Aspecto de ojo de gallo en la hoja',
      ],
      'tratamiento': 'Mejorar la nutrición del cultivo, especialmente el aporte de potasio y zinc. Aplicar fungicidas preventivos con mancozeb y controlar la humedad relativa del cultivo.',
    },
    {
      'nombre':      'Minador de hojas',
      'cientifico':  'Leucoptera coffeella',
      'nivel':       'Riesgo moderado',
      'color':       Colors.deepOrange,
      'icono':       Icons.pest_control,
      'descripcion': 'Plaga causada por la larva de una polilla que excava galerías dentro del tejido foliar. Las minas o galerías son visibles a contraluz. En infestaciones severas puede causar defoliación masiva y debilitamiento del árbol.',
      'sintomas': [
        'Galerías o minas visibles en las hojas',
        'Manchas blancas o translúcidas en el haz',
        'Enrollamiento y sequedad de las hojas afectadas',
        'Caída prematura de hojas con galerías',
        'Debilitamiento general del árbol',
      ],
      'tratamiento': 'Aplicar insecticidas sistémicos (imidacloprid o clorpirifós) en las primeras etapas de infestación. Eliminar hojas muy afectadas y mantener el cultivo libre de malezas que sirvan de refugio.',
    },
    {
      'nombre':      'Phoma',
      'cientifico':  'Phoma tarda',
      'nivel':       'Bajo riesgo',
      'color':       Colors.brown,
      'icono':       Icons.water_drop_outlined,
      'descripcion': 'Enfermedad fúngica favorecida por temperaturas bajas y alta humedad. Conocida también como "muerte descendente" o "chasparria". Afecta hojas, ramas y frutos en zonas de alta pluviosidad y mal drenaje.',
      'sintomas': [
        'Manchas oscuras de bordes irregulares en hojas',
        'Necrosis que avanza desde los bordes hacia el centro',
        'Muerte descendente de ramas',
        'Lesiones en frutos en estado verde',
        'Mayor incidencia en épocas lluviosas',
      ],
      'tratamiento': 'Mejorar el drenaje del suelo y la aireación del cultivo. Aplicar fungicidas preventivos con base en cobre. Evitar heridas en el tejido vegetal durante las labores de poda.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtradas = _enfermedades
        .where((e) => e['nombre'].toString().toLowerCase().contains(_busqueda.toLowerCase()) ||
                      e['cientifico'].toString().toLowerCase().contains(_busqueda.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Catálogo de patologías',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
              hintText: 'Buscar por nombre o especie...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _busqueda.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => setState(() => _busqueda = ''),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        // Contador de resultados
        if (_busqueda.isNotEmpty)
          Container(
            color: const Color(0xFFF1F8E9),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              '${filtradas.length} resultado${filtradas.length != 1 ? 's' : ''} para "$_busqueda"',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),

        Expanded(
          child: filtradas.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('Sin resultados para "$_busqueda"',
                        style: TextStyle(color: Colors.grey.shade500)),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: filtradas.length,
                  itemBuilder: (_, i) {
                    final e = filtradas[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)
                        ],
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        leading: CircleAvatar(
                          backgroundColor: (e['color'] as Color).withOpacity(0.15),
                          child: Icon(e['icono'] as IconData, color: e['color'] as Color),
                        ),
                        title: Text(e['nombre'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(e['cientifico'],
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (e['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(e['nivel'],
                                style: TextStyle(
                                    fontSize: 11,
                                    color: e['color'] as Color,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ]),
                        children: [
                          Text(e['descripcion'],
                              style: const TextStyle(fontSize: 13, height: 1.5)),
                          const SizedBox(height: 12),
                          const Text('Síntomas:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          ...(e['sintomas'] as List<String>).map((s) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Icon(Icons.circle, size: 7, color: e['color'] as Color),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(s, style: const TextStyle(fontSize: 13))),
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
                                Icon(Icons.medical_services_outlined,
                                    size: 16, color: Color(0xFF2E7D32)),
                                SizedBox(width: 6),
                                Text('Tratamiento',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color(0xFF2E7D32))),
                              ]),
                              const SizedBox(height: 6),
                              Text(e['tratamiento'],
                                  style: const TextStyle(fontSize: 13, height: 1.4)),
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
