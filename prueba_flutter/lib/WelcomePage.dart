import 'package:flutter/material.dart';

class WelcomeDialog extends StatefulWidget {
  final String username;
  final String comunidad;

  WelcomeDialog({required this.username, required this.comunidad});

  @override
  _WelcomeDialogState createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<WelcomeDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 450),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
    );

    _controller.addListener(() {
      setState(() {});
    });

    _controller.forward();

    // Cierra el diálogo automáticamente después de 2 segundos
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        title: const Text(
          'Bienvenid@',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        content: Text(
          ' ${widget.username}!',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),

        // Se ha eliminado el botón 'Aceptar'
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
