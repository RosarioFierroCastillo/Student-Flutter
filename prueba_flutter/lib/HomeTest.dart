import 'package:flutter/material.dart';
import 'package:prueba_flutter/WelcomePage.dart';
import 'package:prueba_flutter/main.dart';
import 'Deudores.dart';
import 'ControlAcceso.dart';
import 'Usuarios.dart';
import 'ConfiguracionCuenta.dart';
import 'Sesion.dart';

Sesion sesion_obj = Sesion();

class HomeTest extends StatefulWidget {
  final String username;
  final String comunidad;

  HomeTest({required this.username, required this.comunidad});

  @override
  _HomeTestState createState() => _HomeTestState();
}

class _HomeTestState extends State<HomeTest> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    Deudores(),
    Usuarios(),
    ControlAcceso(),
  ];

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
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ConfiguracionCuenta()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => Student(sesion_obj: sesion_obj)),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
        backgroundColor: const Color(0xFFC1BFFC), // Mismo color que el login
        elevation: 10,
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFAEB8FC), Color(0xFF5A55A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text(
                  'Menú',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading:
                          const Icon(Icons.settings, color: Color(0xFF5A55A1)),
                      title: const Text('Configuración'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => ConfiguracionCuenta()),
                        );
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.logout, color: Color(0xFF5A55A1)),
                      title: const Text('Cerrar sesión'),
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
            label: 'Deudores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_person),
            label: 'Control de acceso',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF5A55A1), // Mismo color que el login
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white, // Color de fondo
      ),
    );
  }
}
