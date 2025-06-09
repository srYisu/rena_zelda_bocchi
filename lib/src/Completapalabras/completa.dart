import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'palabras_data.dart';
import 'package:rena_zelda_bocchi/src/memorama/juegoTerminado.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  int indiceActual = 0;
  int puntaje = 0;
  List<Palabra> palabrasJuego = [];
  bool bloqueado = false;
  Color feedbackColor = Colors.transparent;
  String? palabraMostrada; // Para mostrar la palabra completa si es correcta

  @override
  void initState() {
    super.initState();
    palabrasJuego = List.of(BancoPalabras.obtenerPalabras())..shuffle();
    palabrasJuego = palabrasJuego.take(5).toList();
    _initTts();
    _speak("Selecciona la letra correcta para completar la palabra");
    _speakPalabraActual();
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

  void _speakPalabraActual() {
    final palabra = palabrasJuego[indiceActual];
    final completa = palabra.incompleta.replaceAll("_", "") + palabra.correcta;
    _speak(completa);
  }

  String? seleccionTemporal; // Guarda la letra que se clicó la primera vez

  void verificarRespuesta(String seleccion) async {
    if (bloqueado) return;

    final palabra = palabrasJuego[indiceActual];

    // Si es la primera vez que se selecciona esta letra
    if (seleccionTemporal != seleccion) {
      seleccionTemporal = seleccion;

      String palabraFormada =
          palabra.incompleta.replaceAll("_", "") +
          seleccion; // Ej: "so" + "l" = "sol"

      await _flutterTts.stop();
      await _flutterTts.speak("La palabra es: $palabraFormada");

      return; // NO continúa a verificar todavía
    }

    // Segunda vez que se da clic a la misma letra: ahora verifica
    bloqueado = true;

    final esCorrecto = seleccion == palabra.correcta;

    setState(() {
      feedbackColor =
          esCorrecto
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3);
      palabraMostrada = palabra.incompleta.replaceAll("_", "") + seleccion;
    });

    if (esCorrecto) {
      puntaje++;
      await _audioPlayer.setVolume(0.1);
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } else {
      await _audioPlayer.setVolume(0.05);
      await _audioPlayer.play(AssetSource('sounds/incorrect.mp3'));
    }

    await Future.delayed(Duration(milliseconds: 700));

    setState(() {
      feedbackColor = Colors.transparent;
      palabraMostrada = null;
      seleccionTemporal = null;

      if (indiceActual < palabrasJuego.length - 1) {
        indiceActual++;
        _speakPalabraActual(); // Habla la siguiente palabra
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
                levelId: 4,
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
      body: Stack(
        children: [
          // Fondo de parque
          Positioned.fill(
            child: Image.asset('assets/images/parque.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Center(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                color: feedbackColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 48),
                    Text(
                      "Completa!",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 60),
                    // Icono de pista
                    Card(
                      color: Colors.amber[200],
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(
                          palabra.icono,
                          size: 48,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    // Palabra en un Card decorativo
                    Card(
                      color: Colors.amber[200],
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 38,
                          vertical: 18,
                        ),
                        child: Text(
                          palabraMostrada ?? palabra.incompleta,
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 70),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Ajusta el tamaño de los botones y texto según el ancho disponible
                        double ancho = constraints.maxWidth;
                        double btnPadding =
                            ancho < 400
                                ? 18
                                : ancho < 600
                                ? 28
                                : 32;
                        double fontSize =
                            ancho < 400
                                ? 18
                                : ancho < 600
                                ? 22
                                : 28;

                        return Wrap(
                          spacing: ancho < 400 ? 12 : 32,
                          runSpacing: ancho < 400 ? 12 : 32,
                          children:
                              palabra.opciones.map((op) {
                                return ElevatedButton(
                                  onPressed:
                                      bloqueado
                                          ? null
                                          : () => verificarRespuesta(op),
                                  child: Text(
                                    op,
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: btnPadding,
                                      vertical: btnPadding,
                                    ),
                                    elevation: 6,
                                  ),
                                );
                              }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
