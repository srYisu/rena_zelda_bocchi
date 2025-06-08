import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rena_zelda_bocchi/src/memorama/juegoTerminado.dart';

class Carta {
  final int valor;
  final bool esNumero;
  bool emparejado;

  Carta({required this.valor, required this.esNumero, this.emparejado = false});
}

class EmparejarVisual extends StatefulWidget {
  const EmparejarVisual({super.key});

  @override
  State<EmparejarVisual> createState() => _EmparejarVisualState();
}

class _EmparejarVisualState extends State<EmparejarVisual> {
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
  }

  void generarCartas() {
    final random = Random();
    final valores = <int>{};

    while (valores.length < 3) {
      valores.add(random.nextInt(5) + 1);
    }

    final lista = valores.toList();

    numeros =
        lista.map((v) => Carta(valor: v, esNumero: true)).toList()..shuffle();
    iconos =
        lista.map((v) => Carta(valor: v, esNumero: false)).toList()..shuffle();

    seleccion = null;
    aciertos = 0;
  }

  void manejarToque(Carta carta) {
    if (carta.emparejado || errorActivo) return;

    if (seleccion == null) {
      setState(() {
        seleccion = carta;
      });
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

  Widget construirCarta(Carta carta) {
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
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              carta.emparejado
                  ? Colors.green[100]
                  : estaEnError
                  ? Colors.red[100]
                  : Colors.white,
          border: Border.all(
            color:
                carta.emparejado
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
        child:
            carta.esNumero
                ? Text('${carta.valor}', style: const TextStyle(fontSize: 28))
                : Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: List.generate(
                    carta.valor,
                    (_) => const Icon(Icons.bug_report, size: 20),
                  ),
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emparejar Visual'), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text('Ronda $ronda / $totalRondas'),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: ronda / totalRondas,
            color: Colors.teal,
            minHeight: 8,
          ),
          const SizedBox(height: 10),
          Text('Puntos: $puntos'),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: numeros.map(construirCarta).toList(),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: iconos.map(construirCarta).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
