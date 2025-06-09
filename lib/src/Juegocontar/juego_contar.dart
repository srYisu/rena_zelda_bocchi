import 'dart:math';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rena_zelda_bocchi/src/memorama/juegoTerminado.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(MaterialApp(home: ContarJuego(), debugShowCheckedModeBanner: false));
}

class ContarJuego extends StatefulWidget {
  @override
  State<ContarJuego> createState() => _ContarJuegoState();
}
final List<Icon> iconosDisponibles = [
  Icon(MdiIcons.sheep, color: Colors.blueGrey),
  Icon(MdiIcons.cow, color: Colors.brown),
  Icon(MdiIcons.horse, color: Colors.blue),
  Icon(MdiIcons.duck, color: Colors.yellow),
  Icon(MdiIcons.pig, color: Colors.pinkAccent),
  Icon(MdiIcons.rabbitVariant, color: Colors.deepOrange),
];

class _ContarJuegoState extends State<ContarJuego> {
  final FlutterTts _flutterTts = FlutterTts();
  int? ultimaOpcionSeleccionada;
  late Icon iconoActual;
  int cantidad = 0;
  late List<int> opciones;
  int rondaActual = 0;
  int puntaje = 0;
  bool bloqueado = false;
  Color feedbackColor = Colors.transparent;

  final int totalRondas = 6;
  final int maxCantidad = 10;

  @override
  void initState() {
    super.initState();
    _initTts();
    generarNuevaRonda();
  }
  void _initTts() async {
  await _flutterTts.setLanguage("es-ES");
  await _flutterTts.setPitch(1.0); //tono de voz
  await _flutterTts.setSpeechRate(0.5); // velocidad de voz
}
Future<void> _speak(String text) async {
  await _flutterTts.stop(); // para evitar que se empalmen
  await _flutterTts.setSpeechRate(0.5);
  await _flutterTts.speak(text);
}

  void generarNuevaRonda() {
    final random = Random();
    cantidad = random.nextInt(maxCantidad) + 1;

    iconoActual = iconosDisponibles[random.nextInt(iconosDisponibles.length)];

    opciones = [cantidad];
    while (opciones.length < 3) {
      int opc = random.nextInt(maxCantidad) + 1;
      if (!opciones.contains(opc)) {
        opciones.add(opc);
      }
    }
    opciones.shuffle();
  }

  void manejarToqueBoton(int opcion) async {
  if (bloqueado) return;

  if (ultimaOpcionSeleccionada != opcion) {
    ultimaOpcionSeleccionada = opcion;
    await _speak("$opcion");
  } else {
    verificarRespuesta(opcion);
    ultimaOpcionSeleccionada = null;
  }
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
    setState(() => feedbackColor = Colors.transparent);
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
                levelId: 3,
                estrellas: calcularEstrellas(puntaje),
              ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final primeraFila = cantidad <= 5 ? cantidad : 5;
    final segundaFila = cantidad > 5 ? cantidad - 5 : 0;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/FondoContar.png',
              fit: BoxFit.cover,
            ),
          ),
          AnimatedContainer(
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
    child: GestureDetector(
      onTap: (){
        _speak("Hay $cantidad animales");
      },
      child: AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
              primeraFila,
              (index) => Icon(
                iconoActual.icon,
                size: 48,
                color: iconoActual.color,
              ),
            ),
          ),
          if (segundaFila > 0) const SizedBox(height: 10),
          if (segundaFila > 0)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                segundaFila,
                (index) => Icon(
                  iconoActual.icon,
                  size: 48,
                  color: iconoActual.color,
                ),
              ),
            ),
        ],
      ),
    ),
    )
  ),
),
                  const SizedBox(height: 20), // Espacio entre íconos y botones
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 16,
                      children:
                          opciones.map((opcion) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 20,
                                ),
                              ),
                              onPressed: bloqueado ? null : () => manejarToqueBoton(opcion),
                              child: Text(
                                '$opcion',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
