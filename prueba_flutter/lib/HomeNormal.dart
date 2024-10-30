import 'package:flutter/material.dart';
import 'package:prueba_flutter/WelcomePage.dart';
import 'package:prueba_flutter/main.dart';
import 'Deudores.dart';
import 'ControlAcceso.dart';
import 'Usuarios.dart';
import 'WelcomePage.dart';
import 'ConfiguracionCuenta.dart';

import 'Sesion.dart';
import 'MisDeudas.dart';
import 'GenerarQr.dart';

Sesion sesion_obj = new Sesion();

class HomeNormal extends StatefulWidget {
  final String username;
  final String comunidad;

  HomeNormal({required this.username, required this.comunidad});

  @override
  _HomeNormalState createState() => _HomeNormalState();
}

class _HomeNormalState extends State<HomeNormal> {
  int _selectedIndex = 0;

  // Lista de widgets para mostrar en cada ítem de la barra de navegación
  final List<Widget> _widgetOptions = <Widget>[MisDeudas(), GenerarQr()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return WelcomeDialog(
              username: widget.username, comunidad: widget.comunidad);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/disenio.png',
              fit: BoxFit.cover,
              width: 100,
              height: 40,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.settings,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ConfiguracionCuenta()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => Student(sesion_obj: sesion_obj)),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
        backgroundColor: const Color(0xFFC1BFFC),
        elevation: 10, // Color de fondo de la AppBar
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
              height: 120,
              color: const Color(0xFFC1BFFC), // Fondo del DrawerHeader
              child: const Center(
                child: Text(
                  'Menú',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // ListTile(
                    //   trailing: const Icon(Icons.qr_code),
                    //   title: Text('Generar QR'),
                    //   titleAlignment: ListTileTitleAlignment.center,
                    //   enableFeedback: true,
                    //   hoverColor: Color(0xFFC1BFFC),
                    //   onTap: () {
                    //     Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //           builder: (context) => ConfiguracionCuenta()),
                    //     );
                    //   },
                    // ),
                    ListTile(
                      trailing: const Icon(Icons.settings),
                      title: const Text('Configuración'),
                      titleAlignment: ListTileTitleAlignment.center,
                      enableFeedback: true,
                      hoverColor: const Color(0xFFC1BFFC),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => ConfiguracionCuenta()),
                        );
                      },
                    ),
                    ListTile(
                      trailing: const Icon(Icons.logout),
                      title: const Text('Cerrar sesión'),
                      titleAlignment: ListTileTitleAlignment.center,
                      enableFeedback: true,
                      hoverColor: Color(0xFFC1BFFC),
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) =>
                                  Student(sesion_obj: sesion_obj)),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Mis Deudas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'Generar QR',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFC1BFFC),
        onTap: _onItemTapped,
      ),
    );
  }
}


// appbar con sidenav Hamburguesa

// appBar: AppBar(
//         title: Text("HomePage\n" "${widget.comunidad}"),
//         automaticallyImplyLeading:
//             true, // Habilita el botón del menú hamburguesa
//         centerTitle: true,
//         backgroundColor: Color(0xFFC1BFFC),
//         // actions: <Widget>[
//         //   IconButton(
//         //     icon: Icon(Icons.logout),
//         //     onPressed: () {
//         //       Navigator.of(context).pushAndRemoveUntil(
//         //         MaterialPageRoute(
//         //             builder: (context) => Student(sesion_obj: sesion_obj)),
//         //         (Route<dynamic> route) => false,
//         //       );
//         //       // Aquí va la lógica para cerrar la sesión
//         //     },
//         //   ),
//         // ],
//       ),