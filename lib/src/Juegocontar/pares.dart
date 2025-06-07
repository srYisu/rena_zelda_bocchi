import 'dart:math';
import 'package:flutter/material.dart';

class Carta {
  final int valor;
  final bool esNumero;
  bool emparejado;

  Carta({required this.valor, required this.esNumero, this.emparejado = false});
}

class EmparejarVisual extends StatefulWidget {
  @override
  State<EmparejarVisual> createState() => _EmparejarVisualState();
}

class _EmparejarVisualState extends State<EmparejarVisual> {
  List<Carta> numeros = [];
  List<Carta> iconos = [];

  Carta? seleccionActual;

  @override
  void initState() {
    super.initState();
    generarCartas();
  }

  void generarCartas() {
    final random = Random();
    final valoresUnicos = <int>{};

    while (valoresUnicos.length < 3) {
      valoresUnicos.add(random.nextInt(5) + 1);
    }

    final valores = valoresUnicos.toList()..shuffle();

    setState(() {
      numeros =
          valores.map((v) => Carta(valor: v, esNumero: true)).toList()
            ..shuffle();
      iconos =
          valores.map((v) => Carta(valor: v, esNumero: false)).toList()
            ..shuffle();
      seleccionActual = null;
    });
  }

  void manejarSeleccion(Carta carta) {
    if (carta.emparejado) return;

    if (seleccionActual == null) {
      setState(() {
        seleccionActual = carta;
      });
    } else {
      if (seleccionActual!.esNumero != carta.esNumero &&
          seleccionActual!.valor == carta.valor) {
        setState(() {
          seleccionActual!.emparejado = true;
          carta.emparejado = true;
          seleccionActual = null;
        });
      } else {
        // Mostrar error brevemente
        final previo = seleccionActual!;
        setState(() {
          seleccionActual = null;
        });
        Future.delayed(const Duration(milliseconds: 400), () {
          setState(() {}); // Redibujar para quitar bordes si los usas
        });
      }
    }
  }

  Widget construirCarta(Carta carta) {
    Color borde = Colors.transparent;
    if (carta.emparejado) {
      borde = Colors.green;
    } else if (seleccionActual == carta) {
      borde = Colors.blue;
    }

    return GestureDetector(
      onTap: () => manejarSeleccion(carta),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.teal[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borde, width: 3),
        ),
        child: Center(
          child:
              carta.esNumero
                  ? Text(
                    '${carta.valor}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: List.generate(
                      carta.valor,
                      (_) => const Icon(Icons.bug_report, size: 20),
                    ),
                  ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              '¡Haz par!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: numeros.map(construirCarta).toList(),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: iconos.map(construirCarta).toList(),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: generarCartas,
              child: const Text('Reiniciar'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
