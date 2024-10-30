import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prueba_flutter/Sesion.dart';
import 'package:intl/intl.dart';
import 'Global.dart';
import 'dart:convert';

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

Future<List<Deuda>> fetchMisDeudas() async {
  final response = await http.get(Uri.parse(
      '${global_obj.serverHost}/api/Deudas/Consultar_DeudoresUsuario?id_lote=${Sesion().idPersona}'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((deudas) => Deuda.fromJson(deudas)).toList();
  } else {
    throw Exception('Error al cargar las deudas');
  }
}

class MisDeudas extends StatefulWidget {
  @override
  _MisDeudasState createState() => _MisDeudasState();
}

class _MisDeudasState extends State<MisDeudas> {
  late Future<List<Deuda>> futureDeudas;

  @override
  void initState() {
    super.initState();
    futureDeudas = fetchMisDeudas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Deudas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF3F4F6),
      ),
      body: FutureBuilder<List<Deuda>>(
        future: futureDeudas,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Deuda deuda = snapshot.data![index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        deuda.nombre_deuda,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monto: \$${deuda.monto} MXN',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.red),
                          ),
                          Text(
                            'Estado: ${deuda.estado}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.info_outline),
                        color: const Color(0xFF5A55A1),
                        onPressed: () {
                          detallesDeuda(context, deuda);
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      backgroundColor: const Color(0xFFF3F4F6),
    );
  }
}

void detallesDeuda(BuildContext context, Deuda deuda) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Detalles de la deuda #${deuda.id_deuda}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfoRow('Nombre de la deuda', deuda.nombre_deuda),
              _buildUserInfoRow('Monto', 'MX\$${deuda.monto}'),
              _buildUserInfoRow('Estado', deuda.estado),
              _buildUserInfoRow('Fecha de pago', deuda.proximo_pago),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Widget _buildUserInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
        Icon(Icons.circle, size: 8, color: const Color(0xFF5A55A1)),
        const SizedBox(width: 8),
        Expanded(
          child: Text('$label: $value', style: const TextStyle(fontSize: 16)),
        ),
      ],
    ),
  );
}
