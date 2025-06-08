import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rena_zelda_bocchi/src/memorama/juegoTerminado.dart';

class SumasApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: JuegoSumas());
  }
}

class JuegoSumas extends StatefulWidget {
  @override
  _JuegoSumasState createState() => _JuegoSumasState();
}

class _JuegoSumasState extends State<JuegoSumas>
    with SingleTickerProviderStateMixin {
  int preguntaActual = 0;
  int puntaje = 0;
  bool bloqueado = false;
  List<Pregunta> preguntas = [];
  late AnimationController _controller;
  late Animation<double> _animation;
  Color feedbackColor = Colors.white;

  @override
  void initState() {
    super.initState();
    generarPreguntas();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void generarPreguntas() {
    preguntas.clear();
    final random = Random();
    for (int i = 0; i < 5; i++) {
      int a = random.nextInt(9) + 1;
      int b = random.nextInt(9) + 1;
      int resultado = a + b;
      List<int> opciones = [resultado];
      while (opciones.length < 3) {
        int incorrecta = random.nextInt(18) + 1;
        if (!opciones.contains(incorrecta)) {
          opciones.add(incorrecta);
        }
      }
      opciones.shuffle();
      preguntas.add(Pregunta(a, b, resultado, opciones));
    }
  }

  void responder(int seleccion) async {
    if (bloqueado) return;
    bloqueado = true;
    bool esCorrecto = seleccion == preguntas[preguntaActual].respuestaCorrecta;
    if (esCorrecto) puntaje++;

    setState(
      () => feedbackColor = esCorrecto ? Colors.greenAccent : Colors.redAccent,
    );

    await _controller.forward();
    await Future.delayed(Duration(milliseconds: 300));
    await _controller.reverse();

    setState(() {
      feedbackColor = Colors.white;
      if (preguntaActual < preguntas.length - 1) {
        preguntaActual++;
      } else {
        _finalizarJuego();
      }
      bloqueado = false;
    });
  }

  void _finalizarJuego() {
    int estrellas = ((puntaje / preguntas.length) * 3).round();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => GameOverScreen(
              levelId: 6, // Nivel personalizado para este juego
              estrellas: estrellas.toDouble(),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pregunta = preguntas[preguntaActual];

    return Scaffold(
      backgroundColor: feedbackColor,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: LinearProgressIndicator(
                  value: (preguntaActual + 1) / preguntas.length,
                  backgroundColor: Colors.grey[300],
                  color: Colors.indigo,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sumas',
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      '${pregunta.a} + ${pregunta.b} = ?',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          pregunta.opciones.map((op) {
                            return ScaleTransition(
                              scale: _animation,
                              child: ElevatedButton(
                                onPressed: () => responder(op),
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(30),
                                  backgroundColor: Colors.redAccent,
                                ),
                                child: Text(
                                  '$op',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Pregunta {
  final int a;
  final int b;
  final int respuestaCorrecta;
  final List<int> opciones;

  Pregunta(this.a, this.b, this.respuestaCorrecta, this.opciones);
}
