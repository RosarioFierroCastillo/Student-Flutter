import 'package:flutter/material.dart';
import 'package:prueba_flutter/Sesion.dart';
import 'Global.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Global global_obj = Global();

class Deuda {
  final int id_deuda;
  final int id_deudor;
  final int id_fraccionamiento;
  final String nombre_persona;
  final int lote;
  final String tipo_deuda;
  final String nombre_deuda;
  final int monto;
  final int recargo;
  final int dias_gracia;
  final String proximo_pago;
  final String estado;
  final int periodicidad;

  Deuda({
    required this.id_deuda,
    required this.id_deudor,
    required this.id_fraccionamiento,
    required this.nombre_persona,
    required this.lote,
    required this.tipo_deuda,
    required this.nombre_deuda,
    required this.monto,
    required this.recargo,
    required this.dias_gracia,
    required this.proximo_pago,
    required this.estado,
    required this.periodicidad,
  });

  factory Deuda.fromJson(Map<String, dynamic> json) {
    return Deuda(
      id_deuda: json['id_deuda'],
      id_deudor: json['id_deudor'],
      id_fraccionamiento: json['id_fraccionamiento'],
      nombre_persona: json['nombre_persona'],
      lote: json['lote'],
      tipo_deuda: json['tipo_deuda'],
      nombre_deuda: json['nombre_deuda'],
      monto: json['monto'],
      recargo: json['recargo'],
      dias_gracia: json['dias_gracia'],
      proximo_pago: json['proximo_pago'],
      estado: json['estado'],
      periodicidad: json['periodicidad'],
    );
  }
}

Future<List<Deuda>> fetchDeudores() async {
  final response = await http.get(Uri.parse(
      '${global_obj.serverHost}/api/Deudas/Consultar_DeudoresOrdinarios?id_fraccionamiento=${Sesion().idPersona}'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((deudores) => Deuda.fromJson(deudores)).toList();
  } else {
    throw Exception('Error al cargar las deudas');
  }
}

class Deudores extends StatefulWidget {
  @override
  _DeudoresState createState() => _DeudoresState();
}

class _DeudoresState extends State<Deudores> {
  late Future<List<Deuda>> futureDeudas;

  @override
  void initState() {
    super.initState();
    futureDeudas = fetchDeudores();
  }

  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Deudores de la Comunidad',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        //backgroundColor: const Color(0xFFF3F4F6),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Deuda>>(
          future: futureDeudas,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    futureDeudas = fetchDeudores();
                  });
                },
                child: isSmallScreen
                    ? ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          Deuda deuda = snapshot.data![index];
                          return DeudaCard(deuda: deuda);
                        },
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Ajusta según sea necesario
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 3 / 2,
                        ),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          Deuda deuda = snapshot.data![index];
                          return DeudaCard(deuda: deuda);
                        },
                      ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      backgroundColor: const Color(0xFFF3F4F6),
    );
  }
}

class DeudaCard extends StatelessWidget {
  final Deuda deuda;

  const DeudaCard({Key? key, required this.deuda}) : super(key: key);

  Color getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.red; // Color más llamativo para 'pendiente'
      case 'pagada':
        return Colors.green;
      case 'vencida':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getTipoDeudaIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'mantenimiento':
        return Icons.build;
      case 'servicios':
        return Icons.local_hospital;
      case 'otros':
        return Icons.money;
      default:
        return Icons.money_off_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6, // Aumenta la elevación para mayor prominencia
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bordes más redondeados
      ),
      shadowColor: Colors.grey.withOpacity(0.5), // Sombra más pronunciada
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Indicador de estado en la parte superior
            Align(
              alignment: Alignment.topRight,
              child: Chip(
                label: Text(
                  deuda.estado,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: getEstadoColor(deuda.estado),
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0, vertical: 4.0), // Tamaño del Chip
                labelPadding: const EdgeInsets.all(0),
                avatar: deuda.estado.toLowerCase() == 'pendiente'
                    ? const Icon(
                        Icons.warning,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            // Información principal con icono
            Row(
              children: [
                Icon(
                  getTipoDeudaIcon(deuda.tipo_deuda),
                  size: 30,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID: ${deuda.id_deuda}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Deudor: ${deuda.nombre_persona}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monto: \$${deuda.monto.toStringAsFixed(2)} MXN',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Información adicional
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipo Deuda: ${deuda.tipo_deuda}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fecha de Pago: ${deuda.proximo_pago.substring(0, 10)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
