import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'palabras_data.dart';
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

    if (esCorrecto) {
      puntaje++;
      palabraMostrada = palabra.incompleta.replaceAll("_", "") + seleccion;
      await _audioPlayer.setVolume(0.1);
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
      // Espera a que termine el audio antes de subir el volumen
      _audioPlayer.onPlayerComplete.listen((event) async {
        await _audioPlayer.setVolume(1.0);
      });

      setState(() {});
      await Future.delayed(Duration(milliseconds: 700));
    } else {
      await _audioPlayer.setVolume(0.05);
      await _audioPlayer.play(AssetSource('sounds/incorrect.mp3'));

      // Espera a que termine el audio antes de subir el volumen
      _audioPlayer.onPlayerComplete.listen((event) async {
        await _audioPlayer.setVolume(1.0);
      });

      await Future.delayed(Duration(milliseconds: 500));
    }

    setState(() {
      feedbackColor = Colors.transparent;
      palabraMostrada = null;
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
                    Wrap(
                      spacing: 32,
                      runSpacing: 32,
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
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: CircleBorder(),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 28,
                                ),
                                elevation: 6,
                              ),
                            );
                          }).toList(),
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
