import 'dart:math';
import 'package:flutter/material.dart';
import 'palabras_data.dart'; // archivo externo con las palabras
import 'package:rena_zelda_bocchi/src/memorama/juegoTerminado.dart';

void main() => runApp(CompletarPalabraApp());

class CompletarPalabraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: JuegoCompletarPalabra(),
    );
  }
}

class JuegoCompletarPalabra extends StatefulWidget {
  @override
  _JuegoCompletarPalabraState createState() => _JuegoCompletarPalabraState();
}

class _JuegoCompletarPalabraState extends State<JuegoCompletarPalabra> {
  final Random _random = Random();
  int indiceActual = 0;
  int puntaje = 0;
  List<Palabra> palabrasJuego = [];
  bool bloqueado = false;
  Color feedbackColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    palabrasJuego = List.of(BancoPalabras.obtenerPalabras())..shuffle();
    palabrasJuego = palabrasJuego.take(5).toList();
  }

  void verificarRespuesta(String seleccion) async {
    if (bloqueado) return;
    bloqueado = true;
    final palabra = palabrasJuego[indiceActual];
    bool esCorrecto = seleccion == palabra.correcta;

    setState(() {
      feedbackColor =
          esCorrecto
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3);
    });

    if (esCorrecto) puntaje++;

    await Future.delayed(Duration(milliseconds: 400));

    setState(() {
      feedbackColor = Colors.transparent;
    });

    await Future.delayed(Duration(milliseconds: 200));

    setState(() {
      if (indiceActual < palabrasJuego.length - 1) {
        indiceActual++;
      } else {
        finalizarJuego();
      }
      bloqueado = false;
    });
  }

  void finalizarJuego() {
    double calcularEstrellas(int puntos) {
      if (puntos >= 5) return 3;
      if (puntos >= 3) return 2;
      if (puntos >= 1) return 1;
      return 0;
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => GameOverScreen(
                levelId: 4, // Cambia este ID si es otro nivel
                estrellas: calcularEstrellas(puntaje),
              ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final palabra = palabrasJuego[indiceActual];
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            color: feedbackColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LinearProgressIndicator(
                    value: (indiceActual + 1) / palabrasJuego.length,
                    backgroundColor: Colors.grey[300],
                    color: Colors.deepPurple,
                  ),
                ),
                Text(
                  palabra.incompleta,
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                Wrap(
                  spacing: 20,
                  children:
                      palabra.opciones.map((op) {
                        return ElevatedButton(
                          onPressed:
                              bloqueado ? null : () => verificarRespuesta(op),
                          child: Text(op, style: TextStyle(fontSize: 24)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor:
                                Colors.white, // <-- Color del texto
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
