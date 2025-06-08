import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rena_zelda_bocchi/src/memorama/juegoTerminado.dart'; // Asegúrate que existe este archivo

void main() {
  runApp(MaterialApp(home: ContarJuego(), debugShowCheckedModeBanner: false));
}

class ContarJuego extends StatefulWidget {
  @override
  State<ContarJuego> createState() => _ContarJuegoState();
}

class _ContarJuegoState extends State<ContarJuego> {
  int cantidad = 0;
  late List<int> opciones;
  int rondaActual = 0;
  int puntaje = 0;
  bool bloqueado = false;
  Color feedbackColor = Colors.transparent;

  final int totalRondas = 6;

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

  void verificarRespuesta(int seleccionada) async {
    if (bloqueado) return;
    bloqueado = true;

    final esCorrecta = seleccionada == cantidad;

    if (esCorrecta) puntaje++;

    setState(() {
      feedbackColor =
          esCorrecta
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3);
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      feedbackColor = Colors.transparent;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      rondaActual++;
      if (rondaActual < totalRondas) {
        generarNuevaRonda();
        bloqueado = false;
      } else {
        finalizarJuego();
      }
    });
  }

  void finalizarJuego() {
    double calcularEstrellas(int puntos) {
      if (puntos >= 6) return 3;
      if (puntos >= 4) return 2;
      if (puntos >= 2) return 1;
      return 0;
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => GameOverScreen(
                levelId: 3, // Cambia según tu sistema
                estrellas: calcularEstrellas(puntaje),
              ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: feedbackColor,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                '¡A contar!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LinearProgressIndicator(
                  value: rondaActual / totalRondas,
                  backgroundColor: Colors.grey[300],
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(
                      cantidad,
                      (index) => const Icon(
                        Icons.bug_report,
                        size: 48,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    opciones
                        .map(
                          (opcion) => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            onPressed:
                                bloqueado
                                    ? null
                                    : () => verificarRespuesta(opcion),
                            child: Text(
                              '$opcion',
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
