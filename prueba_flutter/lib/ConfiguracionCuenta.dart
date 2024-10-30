import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Sesion.dart';
import 'Global.dart';

Sesion sesion_obj = Sesion();
Global global_obj = new Global();

class Usuario {
  final int id_persona;
  String nombre;
  String apellido_pat;
  String apellido_mat;
  String telefono;
  final int id_fraccionamiento;
  final int id_lote;
  final int? intercomunicador;
  final String? codigo_acceso;
  String fecha_nacimiento;
  final String correo;
  String contrasenia;
  final String tipo_usuario;
  final String? hikvision;

  Usuario(
      {required this.id_persona,
      required this.nombre,
      required this.apellido_pat,
      required this.apellido_mat,
      required this.telefono,
      required this.id_fraccionamiento,
      required this.id_lote,
      required this.intercomunicador,
      required this.codigo_acceso,
      required this.fecha_nacimiento,
      required this.tipo_usuario,
      required this.correo,
      required this.contrasenia,
      required this.hikvision});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id_persona: json['id_persona'],
      nombre: json['nombre'],
      apellido_pat: json['apellido_pat'],
      apellido_mat: json['apellido_mat'],
      telefono: json['telefono'],
      id_fraccionamiento: json['id_fraccionamiento'],
      id_lote: json['id_lote'],
      intercomunicador: json['intercomunicador'],
      codigo_acceso: json['codigo_acceso'],
      fecha_nacimiento: json['fecha_nacimiento'],
      tipo_usuario: json['tipo_usuario'],
      correo: json['correo'],
      contrasenia: json['contrasenia'],
      hikvision: json['hikvision'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_persona': id_persona,
      'nombre': nombre,
      'apellido_pat': apellido_pat,
      'apellido_mat': apellido_mat,
      'telefono': telefono,
      'id_lote': id_lote,
      'intercomunicador': intercomunicador,
      'codigo_acceso': codigo_acceso,
      'fecha_nacimiento': fecha_nacimiento,
      'tipo_usuario': tipo_usuario,
      'correo': correo,
      'hikvision': hikvision,
      'contrasenia': contrasenia,
    };
  }
}

class ConfiguracionCuenta extends StatefulWidget {
  @override
  _ConfiguracionCuentaState createState() => _ConfiguracionCuentaState();
}

class _ConfiguracionCuentaState extends State<ConfiguracionCuenta> {
  late TextEditingController _nombreController;
  late TextEditingController _apellidoPatController;
  late TextEditingController _apellidoMatController;
  late TextEditingController _telefonoController;
  late TextEditingController _fechaNacimientoController;
  late TextEditingController _ContraseniaController;
  late Future<List<Usuario>> futureUsuario;
  List<Usuario> usuario = [];
  List<Usuario> usuario2 = [];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _apellidoPatController = TextEditingController();
    _apellidoMatController = TextEditingController();
    _telefonoController = TextEditingController();
    _fechaNacimientoController = TextEditingController();
    _ContraseniaController = TextEditingController();
    futureUsuario = fetchUsuario();

    futureUsuario.then((result) {
      setState(() {
        usuario = result;
        if (usuario.isNotEmpty) {
          _nombreController.text = usuario[0].nombre;
          _apellidoPatController.text = usuario[0].apellido_pat;
          _apellidoMatController.text = usuario[0].apellido_mat;
          _telefonoController.text = usuario[0].telefono;
          _fechaNacimientoController.text = usuario[0].fecha_nacimiento;
          _ContraseniaController.text = usuario[0].contrasenia;
          usuario2 = usuario;
        }
      });
    });
  }

  Future<List<Usuario>> fetchUsuario() async {
    final response = await http.get(Uri.parse(
        '${global_obj.serverHost}/api/Personas/Consultar_PersonaIndividual?id_persona=${Sesion().idPersona}'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((user) => Usuario.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load users from API');
    }
  }

  ActualizarUsuario() async {
    if (_nombreController.text == '' || _ContraseniaController.text == '') {
      return;
    } else {
      usuario[0].nombre = _nombreController.text;
      usuario[0].apellido_pat = _apellidoPatController.text;
      usuario[0].apellido_mat = _apellidoMatController.text;
      usuario[0].telefono = _telefonoController.text;
      usuario[0].fecha_nacimiento = _fechaNacimientoController.text;
      usuario[0].contrasenia = _ContraseniaController.text;

      final response = await http.put(
        Uri.parse(
            '${global_obj.serverHost}/api/Personas/Actualizar_Persona'), // Reemplaza con tu URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(usuario[0].toJson()),
      );

      if (response.statusCode == 200) {
        showAlertDialog(context, 'Actualizado',
            'Datos de la cuenta actualizados correctamente');
      } else {
        showAlertDialog(context, 'Error',
            'Por favor verifique los datos ingresados o intentelo de nuevo más tarde');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Configura tu cuenta",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFC1BFFC),
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(50.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Datos Personales",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              buildTextField("", "Ingresa tu nombre", _nombreController),
              buildTextField(
                  "", "Ingresa tu Apellido Paterno", _apellidoPatController),
              buildTextField(
                  "", "Ingresa tu Apellido Materno", _apellidoMatController),
              buildTextField("", "Ingresa tu teléfono", _telefonoController),
              buildTextField(
                  "", "Ingresa tu contraseña", _ContraseniaController),
              Container(
                margin: const EdgeInsets.only(top: 20.0),
                child: TextField(
                  controller: _fechaNacimientoController,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.calendar_today),
                    labelText: _fechaNacimientoController.text.isEmpty
                        ? 'Ingresa tu fecha de nacimiento'
                        : 'Ingresa tu fecha de nacimiento',
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _fechaNacimientoController.text =
                            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                      });
                    }
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 50.0),
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ActualizarUsuario();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A55A1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 40,
                    ),
                  ),
                  child: const Text(
                    "Actualizar",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, String hint, TextEditingController controller) {
    String expresionRegex = '';
    int limiteCaracteres = 0;
    if (controller == _telefonoController) {
      expresionRegex = '[0-9]';
      limiteCaracteres = 10;
    } else if (controller == _ContraseniaController) {
      limiteCaracteres = 20;
      expresionRegex = '[A-Za-z0-9]';
    } else {
      limiteCaracteres = 25;
      expresionRegex = '[A-Za-z ]';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            fontSize: 18,
          ),
        ),
        TextField(
          maxLength: limiteCaracteres,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(expresionRegex)),
          ],
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  showAlertDialog(BuildContext context, String title, String content) {
    // set up the buttons
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
