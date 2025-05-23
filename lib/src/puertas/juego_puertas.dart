import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'banco_preguntas.dart';

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

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    siguientePregunta();
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

  Widget buildPuerta(String opcion) {
    bool esCorrecta = opcion == correcta;
    bool fueSeleccionada = mostrandoResultado && opcion == opcionSeleccionada;
    bool mostrarAbierta = fueSeleccionada && esCorrecta;

    bool esErronea = opcion == _puertaErronea;

    Widget puerta = Image.asset(
      mostrarAbierta ? 'assets/images/popen.png' : 'assets/images/pclosed.png',
      key: ValueKey(mostrarAbierta),
      width: 100,
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
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.lightGreenAccent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(opcion, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 6),
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

  @override
  Widget build(BuildContext context) {
    if (juegoTerminado) {
      return Scaffold(
        appBar: AppBar(title: Text("Juego terminado")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("¡Juego finalizado!", style: TextStyle(fontSize: 24)),
              Text(
                "Puntaje final: $puntos / 10",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    puntos = 0;
                    preguntasRespondidas = 0;
                    juegoTerminado = false;
                    _indicesUsados.clear();
                    siguientePregunta();
                  });
                },
                child: Text("Jugar de nuevo"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Juego de Puertas")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Barra de tiempo
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

              // Barra de progreso de puntaje con texto
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Puertas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildPuerta(opcionesDesordenadas[0]),
                  buildPuerta(opcionesDesordenadas[1]),
                ],
              ),
              SizedBox(height: 30),

              // Icono central
              Icon(preguntaActual.icono, size: 120, color: Colors.deepPurple),
              SizedBox(height: 40),

              // Contador de pregunta
              Text(
                'Pregunta ${min(preguntasRespondidas + (mostrandoResultado ? 0 : 1), 10)} de 10',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
