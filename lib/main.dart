import 'package:flutter/material.dart';
import 'package:rena_zelda_bocchi/src/actividadContar.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            // Fondo de imagen
            SizedBox.expand(
              child: Image.asset(
                'assets/images/FondoMenu.png', // Cambia la ruta si es necesario
                fit: BoxFit.cover,
              ),
            ),
            // Contenido encima del fondo
            Center(
              child: Column(
                children: [
                  Row(
                    children: [
                      Actividadimagen()
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
