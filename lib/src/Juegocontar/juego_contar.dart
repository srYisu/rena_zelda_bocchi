import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: ContarJuego(),
    debugShowCheckedModeBanner: false,
  ));
}

class ContarJuego extends StatefulWidget {
  @override
  State<ContarJuego> createState() => _ContarJuegoState();
}

class _ContarJuegoState extends State<ContarJuego> {
  int cantidad = 0;
  late List<int> opciones;

  @override
  void initState() {
    super.initState();
    generarNuevaRonda();
  }

  void generarNuevaRonda() {
    final random = Random();
    cantidad = random.nextInt(5) + 1; // Entre 1 y 5

    // Generar lista de opciones donde una es la correcta
    opciones = [cantidad];
    while (opciones.length < 3) {
      int opc = random.nextInt(5) + 1;
      if (!opciones.contains(opc)) {
        opciones.add(opc);
      }
    }
    opciones.shuffle();
  }

  void verificarRespuesta(int seleccionada) {
    final esCorrecta = seleccionada == cantidad;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(esCorrecta ? '¡Correcto!' : 'Intenta de nuevo'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                generarNuevaRonda();
              });
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              '¡A contar!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(
                    cantidad,
                    (index) => const Icon(Icons.bug_report,
                        size: 48, color: Colors.black),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: opciones
                  .map(
                    (opcion) => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                      ),
                      onPressed: () => verificarRespuesta(opcion),
                      child: Text(
                        '$opcion',
                        style:
                            const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
