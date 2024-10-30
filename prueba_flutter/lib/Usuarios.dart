import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prueba_flutter/Sesion.dart';
import 'Global.dart';
import 'dart:convert';

Global global_obj = new Global();

class Usuario {
  final int idPersona;
  final String nombre;
  final String apellidoPat;
  final String apellidoMat;
  final String telefono;
  final int idHabitacion;
  final String? intercomunicador;
  final String? codigoAcceso;
  final String fechaNacimiento;
  final String tipoUsuario;
  final String correo;
  final String? hikvision;

  Usuario({
    required this.idPersona,
    required this.nombre,
    required this.apellidoPat,
    required this.apellidoMat,
    required this.telefono,
    required this.idHabitacion,
    required this.intercomunicador,
    required this.codigoAcceso,
    required this.fechaNacimiento,
    required this.tipoUsuario,
    required this.correo,
    required this.hikvision,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idPersona: json['id_persona'],
      nombre: json['nombre'],
      apellidoPat: json['apellido_pat'],
      apellidoMat: json['apellido_mat'],
      telefono: json['telefono'],
      idHabitacion: json['id_lote'],
      intercomunicador: json['intercomunicador'],
      codigoAcceso: json['codigo_acceso'],
      fechaNacimiento: json['fecha_nacimiento'],
      tipoUsuario: json['tipo_usuario'],
      correo: json['correo'],
      hikvision: json['hikvision'],
    );
  }
}

Future<List<Usuario>> fetchUsuarios() async {
  final response = await http.get(Uri.parse(
      '${global_obj.serverHost}/api/Personas/Consultar_Persona?id_administrador=${Sesion().idPersona}'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((user) => Usuario.fromJson(user)).toList();
  } else {
    throw Exception('Error al cargar los usuarios desde la API');
  }
}

class Usuarios extends StatefulWidget {
  @override
  _UsuariosState createState() => _UsuariosState();
}

class _UsuariosState extends State<Usuarios> {
  late Future<List<Usuario>> futureUsuarios;

  @override
  void initState() {
    super.initState();
    futureUsuarios = fetchUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Miembros de la comunidad',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        //backgroundColor: const Color(0xFFF3F4F6), // Color de la AppBar
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Usuario>>(
          future: futureUsuarios,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return isSmallScreen
                  ? ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Usuario usuario = snapshot.data![index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF5A55A1),
                              child: Text(
                                usuario.nombre[0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              '${usuario.nombre} ${usuario.apellidoPat} ${usuario.apellidoMat}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text('Teléfono: ${usuario.telefono}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.info_outline,
                                  color: Color(0xFF5A55A1)),
                              onPressed: () {
                                detallesUsuario(context, usuario);
                              },
                            ),
                            onTap: () {
                              detallesUsuario(context, usuario);
                            },
                          ),
                        );
                      },
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => const Color(0xFF5A55A1)),
                        columnSpacing: 20.0,
                        columns: const [
                          DataColumn(label: Text('#')),
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Teléfono')),
                          DataColumn(label: Text('Acción')),
                        ],
                        rows: snapshot.data!
                            .map((Usuario usuario) => DataRow(
                                  cells: [
                                    DataCell(Text('${usuario.idPersona}')),
                                    DataCell(Text(
                                        '${usuario.nombre} ${usuario.apellidoPat} ${usuario.apellidoMat}')),
                                    DataCell(Text(usuario.telefono)),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.info_outline,
                                            color: Colors.white),
                                        onPressed: () {
                                          detallesUsuario(context, usuario);
                                        },
                                      ),
                                    ),
                                  ],
                                  onSelectChanged: (selected) {
                                    if (selected != null && selected) {
                                      detallesUsuario(context, usuario);
                                    }
                                  },
                                ))
                            .toList(),
                      ),
                    );
            } else if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      backgroundColor: const Color(0xFFF3F4F6), // Fondo de la página
    );
  }
}

const TextStyle commonTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  color: Colors.black54,
);

void detallesUsuario(BuildContext context, Usuario usuario) {
  String nombreCompleto =
      '${usuario.nombre.toUpperCase()} ${usuario.apellidoPat.toUpperCase()} ${usuario.apellidoMat.toUpperCase()}';
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('$nombreCompleto #${usuario.idPersona}',
            style: TextStyle(color: const Color(0xFF5A55A1))),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfoRow('Teléfono', usuario.telefono),
              _buildUserInfoRow('Correo', usuario.correo),
              _buildUserInfoRow('Fecha de Nacimiento', usuario.fechaNacimiento),
              _buildUserInfoRow('Tipo de Usuario', usuario.tipoUsuario),
              _buildUserInfoRow(
                  'Acceso a la Comunidad', usuario.hikvision ?? 'N/A'),
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

Widget _buildUserInfoRow(String label, String? value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
        Icon(Icons.circle, size: 8, color: const Color(0xFF5A55A1)),
        const SizedBox(width: 8),
        Expanded(
          child: Text('$label: $value', style: commonTextStyle),
        ),
      ],
    ),
  );
}
