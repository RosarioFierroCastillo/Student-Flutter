import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prueba_flutter/Sesion.dart';
import 'dart:convert';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart'; // Importa el paquete aquí
import 'Global.dart';
import 'package:permission_handler/permission_handler.dart';

Global global_obj = new Global();
Sesion sesion_obj = Sesion();

String token = '';
String urlAccesoTemporal =
    '${global_obj.serverHost}/Student/PaseTemporal?token=';

class GenerarQr extends StatefulWidget {
  @override
  _GenerarQrState createState() => _GenerarQrState();
}

class _GenerarQrState extends State<GenerarQr> {
  String qrCodeUrl = '';
  late TextEditingController _tokenController;
  late TextEditingController _urlAccesoTemporal;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController();
    _urlAccesoTemporal = TextEditingController();

    consultarToken().then((value) {
      if (token == 'error') {
        showAlertDialog(context, 'Genere su código',
            'Aún no cuenta con una invitación activa, por favor genere una');
      } else {
        showAlertDialog(context, 'Invitación Existente',
            'Ya tiene una invitación activa, no podrá generar otra hasta que sea usada. Se cargará automáticamente el código QR');
        setState(() {
          _urlAccesoTemporal.text =
              '${global_obj.serverHost}/Student/PaseTemporal?token=$token';
        });
      }
    });
  }

  Future<void> generateQrCode() async {
    if (token == '' || token == 'error') {
// Llama a la función para generar el token y espera a que se complete
      await generarToken();

      // Actualiza el texto de la URL con el token generado
      setState(() {
        _urlAccesoTemporal.text =
            '${global_obj.serverHost}/Student/PaseTemporal?token=$token';
      });

      // Imprime el token generado (solo para verificar)
      print(token);
    } else {
      showAlertDialog(context, 'Invitación Existente',
          'Por favor use la invitación existente antes de generar otra');
    }
  }

  void shareQrCode() {
    Share.share(_tokenController.text,
        subject: 'Aquí está tu código QR',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 200, 200));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Invitaciones',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            QrImageView(
              data: _urlAccesoTemporal.text,
              version: QrVersions.auto,
              size: 350.0,
            ),
            ElevatedButton(
              onPressed: generateQrCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A55A1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 80,
                ),
              ),
              child: const Text(
                "Generar QR",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              //child: const Text('Generar QR'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> generarToken() async {
  final url = Uri.parse(
      '${global_obj.serverHost}/api/Whatsapp/Generar_Token?idUsuario=${Sesion().idPersona}');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Si la solicitud fue exitosa, devuelve el contenido de la respuesta
      token = response.body.toString();
      return response.body;
    } else {
      // Si la solicitud no fue exitosa, imprime el código de estado de la respuesta
      print(
          'Error al generar el token. Código de estado: ${response.statusCode}');
      return 'error';
    }
  } catch (e) {
    // Si ocurre un error durante la solicitud, imprime el error
    print('Excepción al generar el token: $e');
    return 'error';
  }
}

Future<String> consultarToken() async {
  final url = Uri.parse(
      '${global_obj.serverHost}/api/Whatsapp/Consultar_Token_Activo?idUsuario=${Sesion().idPersona}');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Si la solicitud fue exitosa, devuelve el contenido de la respuesta
      token = response.body.toString();
      print(
          "TOKEN RECIBIDO CUANDO NO HAY NADA EN LA BD!!!!AAAAAAAAAAAAAAAAAAAAAAAAAAAAA" +
              token);
      return response.body;
    } else {
      // Si la solicitud no fue exitosa, imprime el código de estado de la respuesta
      print(
          'Error al generar el token. Código de estado: ${response.statusCode}');
      token = response.body.toString();
      return 'error';
    }
  } catch (e) {
    // Si ocurre un error durante la solicitud, imprime el error
    print('Excepción al generar el token: $e');
    return 'error';
  }
}

showAlertDialog(BuildContext context, String titulo, String contenido) {
  // set up the buttons

  // Widget cancelButton = TextButton(
  //   child: Text("Cancel"),
  //   onPressed: () {
  //     Navigator.of(context).pop();
  //   },
  // );
  Widget continueButton = TextButton(
    child: const Text("Aceptar"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(titulo),
    content: Text(contenido),
    actions: [
      // cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(titulo),
        content: Text(contenido),
        actions: [
          TextButton(
            child: const Text("Aceptar"),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      );
    },
  );
}
