import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'banco_preguntas.dart';
import 'package:rena_zelda_bocchi/src/memorama/juegoTerminado.dart';
import 'package:flutter_tts/flutter_tts.dart';

class JuegoPantalla extends StatefulWidget {
  @override
  _JuegoPantallaState createState() => _JuegoPantallaState();
}

class _JuegoPantallaState extends State<JuegoPantalla>
    with TickerProviderStateMixin {
  final banco = BancoPreguntas();
  final Random _random = Random();
  final player = AudioPlayer();
  String? opcionSeleccionada;

  late Pregunta preguntaActual;
  late String correcta;
  late List<String> opcionesDesordenadas;

  int puntos = 0;
  int preguntasRespondidas = 0;
  bool mostrandoResultado = false;
  bool juegoTerminado = false;

  List<int> _indicesUsados = [];
  String? _puertaErronea;

  Timer? _timer;
  int tiempoRestante = 10;
  final int tiempoMaximo = 10;

  late AnimationController _shakeController;

  late FlutterTts _flutterTts;
  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _flutterTts = FlutterTts();
    _initTts();
    _speak("Selecciona la puerta correcta para cada objeto.");
    siguientePregunta();
  }
      void _initTts() async {
  await _flutterTts.setLanguage("es-ES");
  await _flutterTts.setPitch(1.0); //tono de voz
  await _flutterTts.setSpeechRate(0.5); // velocidad de voz
}
  Future<void> _speak(String text) async {
  await _flutterTts.stop(); // para evitar que se empalmen
  await _flutterTts.setSpeechRate(0.5); // velocidad de voz
  await _flutterTts.speak(text);
}

  @override
  void dispose() {
    _shakeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void siguientePregunta() {
    if (_indicesUsados.length == 10) {
      setState(() {
        juegoTerminado = true;
      });
      return;
    }

    int nuevoIndice;
    do {
      nuevoIndice = _random.nextInt(banco.preguntas.length);
    } while (_indicesUsados.contains(nuevoIndice));

    _indicesUsados.add(nuevoIndice);
    preguntaActual = banco.preguntas[nuevoIndice];
    correcta = preguntaActual.correcta;

    opcionesDesordenadas = [preguntaActual.opcion1, preguntaActual.opcion2];
    opcionesDesordenadas.shuffle();

    setState(() {
      mostrandoResultado = false;
      tiempoRestante = tiempoMaximo;
      _puertaErronea = null;
    });
    _speak(preguntaActual.correcta);

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        tiempoRestante--;
        if (tiempoRestante == 0) {
          _timer?.cancel();
          mostrarResultadoTiempoAgotado();
        }
      });
    });
  }

  void mostrarResultadoTiempoAgotado() {
    setState(() {
      mostrandoResultado = true;
      preguntasRespondidas++;
      _puertaErronea = opcionesDesordenadas.firstWhere((op) => op != correcta);
      _shakeController.forward(from: 0);
      player.play(AssetSource('sounds/closed.mp3'));
    });

    Timer(Duration(seconds: 2), () {
      siguientePregunta();
    });
  }

  void verificarRespuesta(String seleccionada) {
    if (mostrandoResultado) return;

    _timer?.cancel();

    setState(() {
      opcionSeleccionada = seleccionada;
      mostrandoResultado = true;
      preguntasRespondidas++;
      if (seleccionada == correcta) {
        puntos++;
        player.play(AssetSource('sounds/open.mp3'));
      } else {
        _puertaErronea = seleccionada;
        _shakeController.forward(from: 0);
        player.play(AssetSource('sounds/close.mp3'));
      }
    });

    Timer(Duration(seconds: 1), () {
      siguientePregunta();
    });
  }

  Widget buildPuerta(String opcion, double anchoPantalla) {
    bool esCorrecta = opcion == correcta;
    bool fueSeleccionada = mostrandoResultado && opcion == opcionSeleccionada;
    bool mostrarAbierta = fueSeleccionada && esCorrecta;
    bool esErronea = opcion == _puertaErronea;

    double anchoPuerta =
        anchoPantalla > 700
            ? 260
            : (MediaQuery.of(context).orientation == Orientation.portrait
                ? 130
                : 100);

    Widget puerta = Image.asset(
      mostrarAbierta ? 'assets/images/popen.png' : 'assets/images/pclosed.png',
      key: ValueKey(mostrarAbierta),
      width: anchoPuerta,
    );

    if (esErronea && mostrandoResultado) {
      puerta = AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          double offset = sin(_shakeController.value * pi * 6.0) * 10;
          return Transform.translate(offset: Offset(offset, 0), child: child);
        },
        child: puerta,
      );
    }

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightGreenAccent, Colors.greenAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 4),
                blurRadius: 6,
              ),
            ],
            border: Border.all(color: Colors.green.shade700, width: 2),
          ),
          child: Text(
            opcion,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green.shade900,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: mostrandoResultado ? null : () => verificarRespuesta(opcion),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            child: puerta,
          ),
        ),
      ],
    );
  }

  void finalizarJuego() {
    double calcularEstrellas(puntos) {
      if (puntos >= 10) return 3;
      if (puntos >= 7) return 2;
      if (puntos >= 4) return 1;
      return 0;
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => GameOverScreen(
                levelId: 2,
                estrellas: calcularEstrellas(puntos),
              ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (juegoTerminado) {
      finalizarJuego();
    }

    final anchoPantalla = MediaQuery.of(context).size.width;
    final bool pantallaAncha = anchoPantalla > 700;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/FondoPuertas.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: tiempoRestante / tiempoMaximo,
                            minHeight: 12,
                            backgroundColor: Colors.red.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        SizedBox(width: 8),
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 500),
                            tween: Tween<double>(begin: 0, end: puntos / 10),
                            builder: (context, value, _) {
                              return LinearProgressIndicator(
                                value: value,
                                minHeight: 12,
                                backgroundColor: Colors.amber.shade100,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.amber,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '$puntos/10',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: pantallaAncha ? 220 : 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildPuerta(opcionesDesordenadas[0], anchoPantalla),
                  buildPuerta(opcionesDesordenadas[1], anchoPantalla),
                ],
              ),
            ],
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 180),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: const Color(0xFFf0d3a6).withOpacity(1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey[700]!, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Icon(
                    preguntaActual.icono,
                    size: 120,
                    color: const Color.fromARGB(255, 199, 64, 54),
                    //color: const Color.fromARGB(255, 223, 169, 23),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${min(preguntasRespondidas + (mostrandoResultado ? 0 : 1), 10)} de 10',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
