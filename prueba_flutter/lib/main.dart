import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:prueba_flutter/HomeNormal.dart';
import 'HomeTest.dart';
import 'Sesion.dart';
import 'WelcomePage.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  Sesion sesion_obj = Sesion();
  String pruebaglobal = '';
  runApp(Student(sesion_obj: sesion_obj));
}

class Student extends StatelessWidget {
  final Sesion sesion_obj;
  const Student({Key? key, required this.sesion_obj}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: LogIn(sesion_obj: sesion_obj),
    );
  }
}

class LogIn extends StatefulWidget {
  final Sesion sesion_obj;
  const LogIn({Key? key, required this.sesion_obj}) : super(key: key);

  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> with SingleTickerProviderStateMixin {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  showAlertDialog(BuildContext context, String titulo, String contenido) {
    Widget continueButton = TextButton(
      child: const Text("Aceptar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(contenido),
          actions: [
            continueButton,
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/disenio.png',
                  height: 100,
                ),
                const SizedBox(height: 30),
                const Text(
                  "Bienvenido",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF5A55A1),
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Correo electrónico",
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    bool inicioSesionExitoso =
                        await widget.sesion_obj.iniciarSesion(
                      _emailController.text,
                      _passwordController.text,
                    );

                    if (inicioSesionExitoso) {
                      if (widget.sesion_obj.tipoUsuario == 'administrador') {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => HomeTest(
                                username: widget.sesion_obj.nombreUsuario,
                                comunidad: widget.sesion_obj.comunidad),
                          ),
                        );
                      } else if (widget.sesion_obj.tipoUsuario == 'usuario') {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => HomeNormal(
                                username: widget.sesion_obj.nombreUsuario,
                                comunidad: widget.sesion_obj.comunidad),
                          ),
                        );
                      } else if (widget.sesion_obj.tipoUsuario == 'tesorero') {
                        showAlertDialog(context, "Proximamente",
                            "Espera nuevas funcionalidades para tesoreros en tu comunidad.");
                      }
                    } else {
                      showAlertDialog(context, "Error",
                          "Por favor verifique su correo y contraseña.");
                    }
                  },
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
                    "Iniciar sesión",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
