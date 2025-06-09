import 'dart:math';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rena_zelda_bocchi/src/memorama/juegoTerminado.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Carta {
  final int valor;
  final bool esNumero;
  final Icon? icono;
  bool emparejado;

  Carta({required this.valor, required this.esNumero, required this.icono, this.emparejado = false});
}

class EmparejarVisual extends StatefulWidget {
  const EmparejarVisual({super.key});

  @override
  State<EmparejarVisual> createState() => _EmparejarVisualState();
}

class _EmparejarVisualState extends State<EmparejarVisual> {
  final FlutterTts _flutterTts = FlutterTts();
  List<Carta> numeros = [];
  List<Carta> iconos = [];

  Carta? seleccion;

  int aciertos = 0;
  int puntos = 0;
  int ronda = 1;
  final int totalRondas = 5;

  bool errorActivo = false;

  @override
  void initState() {
    super.initState();
    generarCartas();
    _initTts();
  }
    void _initTts() async {
  await _flutterTts.setLanguage("es-ES");
  await _flutterTts.setPitch(1.0); //tono de voz
  await _flutterTts.setVolume(0.5); //volumen
  await _flutterTts.setSpeechRate(0.5); // velocidad de voz
}
  Future<void> _speak(String text) async {
  await _flutterTts.stop(); // para evitar que se empalmen
  await _flutterTts.setSpeechRate(0.5);
  await _flutterTts.speak(text);
}
void decirCarta(Carta carta) {
  if (carta.esNumero) {
    _speak("Número ${carta.valor}");
  } else {
    String descripcion = describirIcono(carta.icono);
    _speak("${carta.valor} ${descripcion}");
  }
}
String describirIcono(Icon? icono) {
  if (icono == null) return "íconos";

  final iconData = icono.icon;
  if (iconData == MdiIcons.emoticonHappy) return "caritas felices";
  if (iconData == MdiIcons.starFace) return "caras de estrella";
  if (iconData == MdiIcons.puzzle) return "rompecabezas";
  if (iconData == MdiIcons.cat) return "gatos";
  if (iconData == MdiIcons.unicorn) return "unicornios";
  if (iconData == MdiIcons.robot) return "robots";
  if (iconData == MdiIcons.balloon) return "globos";
  if (iconData == MdiIcons.candycane) return "bastones de caramelo";
  if (iconData == MdiIcons.teddyBear) return "ositos";
  if (iconData == MdiIcons.cupcake) return "pastelitos";

  return "íconos";
}
  void generarCartas() {
    final List<Icon> iconosDisponibles = [
  Icon(MdiIcons.emoticonHappy, color: Colors.amber),
  Icon(MdiIcons.starFace, color: Colors.yellow),
  Icon(MdiIcons.puzzle, color: Colors.blue),
  Icon(MdiIcons.cat, color: Colors.deepOrangeAccent),
  Icon(MdiIcons.unicorn, color: Colors.pinkAccent),
  Icon(MdiIcons.robot, color: Colors.deepPurple),
  Icon(MdiIcons.balloon, color: Colors.redAccent),
  Icon(MdiIcons.candycane, color: Colors.red),
  Icon(MdiIcons.teddyBear, color: Colors.brown),
  Icon(MdiIcons.cupcake, color: Colors.green),
];
    final random = Random();
    final valores = <int>{};

    while (valores.length < 3) {
      valores.add(random.nextInt(10) + 1);
    }

    final lista = valores.toList();

    final iconosShuffle = List<Icon>.from(iconosDisponibles)..shuffle();
    final iconosElegidos = iconosShuffle.take(10).toList();

    numeros = lista.map((v) => Carta(valor: v, esNumero: true, icono: null)).toList()..shuffle();
    iconos = List.generate(3, (i) => Carta(valor: lista[i], esNumero: false, icono: iconosElegidos[i]))..shuffle();

    seleccion = null;
    aciertos = 0;
  }

  void manejarToque(Carta carta) {
    if (carta.emparejado || errorActivo) return;

    if (seleccion == null) {
      setState(() {
        seleccion = carta;
      });
      decirCarta(carta); // <--- aquí
    } else {
      final empareja =
          seleccion!.valor == carta.valor &&
          seleccion!.esNumero != carta.esNumero;

      if (empareja) {
        setState(() {
          carta.emparejado = true;
          seleccion!.emparejado = true;
          seleccion = null;
          puntos++;
          aciertos++;
        });

        if (aciertos == 3) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (ronda == totalRondas) {
              double estrellas =
                  (((puntos / (totalRondas * 3)) * 3).clamp(
                    0.0,
                    3.0,
                  )).floorToDouble();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => GameOverScreen(levelId: 5, estrellas: estrellas),
                ),
              );
            } else {
              setState(() {
                ronda++;
                generarCartas();
              });
            }
          });
        }
      } else {
        setState(() {
          errorActivo = true;
          puntos = max(0, puntos - 1);
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            errorActivo = false;
            seleccion = null;
          });
        });
      }
    }
  }

 // ...existing code...

Widget construirCarta(Carta carta, double cardHeight) {
  final cardWidth = cardHeight * 1.5;
  final estaSeleccionada = seleccion == carta;
  final estaEnError =
      errorActivo &&
      seleccion != null &&
      seleccion!.valor == carta.valor &&
      seleccion!.esNumero != carta.esNumero;

  return GestureDetector(
    onTap: () => manejarToque(carta),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(14),
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: carta.emparejado
            ? Colors.green[100]
            : estaEnError
                ? Colors.red[100]
                : Colors.white,
        border: Border.all(
          color: carta.emparejado
              ? Colors.green
              : estaSeleccionada
                  ? Colors.blue
                  : estaEnError
                      ? Colors.red
                      : Colors.grey,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: carta.esNumero
          ? Center(child: Text('${carta.valor}', style: const TextStyle(fontSize: 28)))
          : Center(
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: List.generate(
                  carta.valor,
                  (_) => carta.icono ?? const Icon(Icons.bug_report),
                ),
              ),
            ),
    ),
  );
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/fondoPares.png',
            fit: BoxFit.cover,
          ),
        ),
        Column(
          children: [
            const SizedBox(height: 50),
            Text('Ronda $ronda / $totalRondas'),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: LinearProgressIndicator(
                value: ronda / totalRondas,
                color: Colors.teal,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 10),
            Text('Puntos: $puntos'),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calcula el tamaño máximo para quepan 3 cartas por columna con márgenes
                  double cardSize = (constraints.maxHeight - 100) / 3 - 16;
                  cardSize = cardSize.clamp(80, 120); // Tamaño mínimo y máximo

                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: numeros
                              .map((carta) => construirCarta(carta, cardSize))
                              .toList(),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: iconos
                              .map((carta) => construirCarta(carta, cardSize))
                              .toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
}