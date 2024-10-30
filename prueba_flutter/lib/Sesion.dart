import 'package:dio/dio.dart';
import 'Global.dart';

Global global_obj = new Global();

int idPersona_global = 0;

class Sesion {
  static final Sesion _singleton = Sesion._internal();

  factory Sesion() {
    return _singleton;
  }

  Sesion._internal();

  String nombreUsuario = '';
  String comunidad = '';
  int idPersona = 0;
  String tipoUsuario = '';
  Future<bool> iniciarSesion(String email, String password) async {
    String nombre = '';

    bool inicioSesion = false;

    // Aquí puedes implementar la lógica de inicio de sesión
    //print("Iniciando sesión con correo: $email y contraseña: $password");

    // URL base de la API
    final String baseUrl = '${global_obj.serverHost}/Sesion/Iniciar_Sesion';

    // Parámetros de la solicitud
    final Map<String, dynamic> queryParams = {
      'correo': email.toString(),
      'contrasenia': password.toString(),
    };

    // Construir la URL de la API utilizando el constructor de Uri
    final Uri apiUrl =
        Uri.parse('$baseUrl').replace(queryParameters: queryParams);

    print(apiUrl.toString());

    try {
      // Crear una instancia de Dio
      var dio = Dio();

      // Configurar los encabezados de la solicitud
      dio.options.headers['Content-Type'] = 'application/json';

      // Configurar Dio para desactivar la verificación del certificado SSL
      dio.options.validateStatus = (_) => true;

      var response = await dio.get(apiUrl.toString());

      if (response.statusCode == 200) {
        print(response.data);

        Map<String, dynamic> user = response.data[0];
        if (user.containsKey('correo')) {
          nombre = user['correo'];
          comunidad = user['fraccionamiento'];
          idPersona = user['id_usuario'];
          idPersona_global = idPersona;
          tipoUsuario = user['tipo_usuario'];
          nombreUsuario = user['correo'];
        }

        inicioSesion = true;
      } else {
        // La solicitud falló, maneja el error aquí
        print('Error al cargar datos: ${response}');
        inicioSesion = false;
      }
    } catch (e) {
      print('Error: $e');
      inicioSesion = false;
    }

    return inicioSesion;

    //showAlertDialog(context, nombre);
  }
}
