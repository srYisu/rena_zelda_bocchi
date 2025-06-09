import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:rena_zelda_bocchi/src/memorama/juegoTerminado.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

class _JuegoSumasState extends State<JuegoSumas> with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  int preguntaActual = 0;
  int puntaje = 0;
  bool bloqueado = false;
  List<Pregunta> preguntas = [];
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  Color feedbackColor = Colors.white;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? respuestaMostrada;

  @override
  void initState() {
    super.initState();
    _initTts();
    _speak("Selecciona la respuesta correcta para cada suma.");
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(
      begin: 1,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticInOut));

    _shakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 16).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    generarPreguntas(); // <-- ¡Agrega esto!
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    super.dispose();
  }
  void _initTts() async {
  await _flutterTts.setLanguage("es-ES");
  await _flutterTts.setPitch(1.0); //tono de voz
  await _flutterTts.setVolume(0.5); //volumen
  await _flutterTts.setSpeechRate(1); // velocidad de voz
}
  Future<void> _speak(String text) async {
  await _flutterTts.stop(); // para evitar que se empalmen
  await _flutterTts.speak(text);
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
    if (esCorrecto) {
      puntaje++;
      respuestaMostrada = seleccion;
      await _audioPlayer.play(AssetSource('sounds/Write.mp3'));
      setState(() => feedbackColor = Colors.greenAccent);
      await _controller.forward();
      await Future.delayed(Duration(milliseconds: 300));
      await _controller.reverse();
    } else {
      respuestaMostrada = null;
      await _audioPlayer.play(AssetSource('sounds/error.mp3'));
      setState(() => feedbackColor = Colors.redAccent);
      await _shakeController.forward();
      await Future.delayed(Duration(milliseconds: 100));
      await _shakeController.reverse();
    }

    setState(() {
      feedbackColor = Colors.white;
      // Avanza a la siguiente pregunta siempre, excepto si es la última (en ambos casos)
      if (preguntaActual < preguntas.length - 1) {
        preguntaActual++;
        respuestaMostrada = null;
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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo de pizarra
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo_pizarra.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.start, // Mueve todo hacia arriba
                children: [
                  SizedBox(
                    height: 24,
                  ), // Espacio superior, ajusta según prefieras
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
                      mainAxisAlignment: MainAxisAlignment.start, // Más arriba
                      children: [
                        SizedBox(
                          height: 20,
                        ), // Espacio entre el indicador y el título
                        Text(
                          'Sumas',
                          style: TextStyle(
                            fontFamily: 'ChalkFont',
                            fontSize: 56, // Más grande
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 40),
                        AnimatedBuilder(
                          animation: _shakeController,
                          builder: (context, child) {
                            double offset =
                                _shakeAnimation.value *
                                sin(
                                  DateTime.now().millisecondsSinceEpoch * 0.05,
                                );
                            return Transform.translate(
                              offset: Offset(offset, 0),
                              child: child,
                            );
                          },
                          child: Text(
                            respuestaMostrada != null
                                ? '${pregunta.a} + ${pregunta.b} = $respuestaMostrada'
                                : '${pregunta.a} + ${pregunta.b} = ?',
                            style: TextStyle(
                              fontFamily: 'ChalkFont',
                              fontSize: 48, // Más grande
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 60),
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
                                      padding: EdgeInsets.all(38), // Más grande
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                    ),
                                    child: Text(
                                      '$op',
                                      style: TextStyle(
                                        fontFamily: 'ChalkFont',
                                        fontSize: 36, // Más grande
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
        ],
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
