import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:prueba_flutter/Sesion.dart';
import 'Global.dart';

Global global_obj = new Global();

class Usuario {
  final int idPersona;
  final String nombre;
  final String apellidoPat;
  final String apellidoMat;
  final String telefono;
  final String tipoUsuario;
  final String correo;
  final String hikvision;

  Usuario({
    required this.idPersona,
    required this.nombre,
    required this.apellidoPat,
    required this.apellidoMat,
    required this.telefono,
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
    throw Exception('Failed to load users from API');
  }
}

class ControlAcceso extends StatefulWidget {
  @override
  _ControlAccesoState createState() => _ControlAccesoState();
}

class _ControlAccesoState extends State<ControlAcceso> {
  late Future<List<Usuario>> futureUsuarios;

  @override
  void initState() {
    super.initState();
    futureUsuarios = fetchUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Control de Acceso de Usuarios',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        // backgroundColor: const Color(0xFFF3F4F6), // Color de la AppBar
        elevation: 1,
      ),
      body: FutureBuilder<List<Usuario>>(
        future: futureUsuarios,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Usuario usuario = snapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${usuario.nombre} ${usuario.apellidoPat} ${usuario.apellidoMat}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text('Hikvision: ${usuario.hikvision}'),
                                Text('Teléfono: ${usuario.telefono}'),
                                Text('Correo: ${usuario.correo}'),
                              ],
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.check_circle,
                                    color: Colors.green),
                                onPressed: () {
                                  enable(usuario);
                                },
                                tooltip: 'Permitir acceso',
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.block, color: Colors.red),
                                onPressed: () {
                                  delete(usuario);
                                },
                                tooltip: 'Restringir acceso',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void delete(Usuario usuario) async {
    Fluttertoast.showToast(
      msg: "Cargando...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );

    final response = await http.get(Uri.parse(
        '${global_obj.serverHost}/api/Usuario_lote/RestrictedUser?id_usuario=${usuario.idPersona}'));

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Usuario restringido correctamente",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );

      setState(() {
        futureUsuarios = fetchUsuarios();
      });
    } else {
      Fluttertoast.showToast(
        msg: "Error al restringir el usuario",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  void enable(Usuario usuario) async {
    Fluttertoast.showToast(
      msg: "Cargando...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );

    final response = await http.get(Uri.parse(
        '${global_obj.serverHost}/api/Usuario_lote/EnableUser?id_usuario=${usuario.idPersona}'));

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Usuario agregado correctamente",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );

      setState(() {
        futureUsuarios = fetchUsuarios();
      });
    } else {
      Fluttertoast.showToast(
        msg: "Error al habilitar el usuario",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }
}
