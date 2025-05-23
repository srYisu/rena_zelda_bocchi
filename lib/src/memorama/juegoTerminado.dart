import 'package:flutter/material.dart';
import 'package:rena_zelda_bocchi/src/memorama/pantallaJuego.dart';
import 'package:rive/rive.dart';

class GameOverScreen extends StatelessWidget {
  final int intentos;

  const GameOverScreen({super.key, required this.intentos});

  @override
  Widget build(BuildContext context) {
String message;
double estrellas;

if (intentos <= 12) {
  message = "¡Excelente memoria!";
  estrellas = 3;
} else if (intentos <= 18) {
  message = "¡Muy bien!";
  estrellas = 2;
} else {
  message = "¡Puedes mejorar!";
  estrellas = 1;
}

    return Scaffold(
      appBar: AppBar(title: const Text("Resultado")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Puntuación: $intentos", style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Text(message, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            SizedBox(
              width: 500,
              height: 500,
              child: RiveAnimation.asset(
                'assets/animations/3estrellas.riv',
                onInit: (artboard) {
                  final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
                  if (controller != null) {
                    artboard.addController(controller);
                    final input = controller.findInput<double>('nEstrellas') as SMINumber?;
                    input!.change(estrellas);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MemoramaGame(), // reinicia completamente la app
      ),
    );
  },
  child: const Text("Jugar de nuevo"),
)
          ],
        ),
      ),
    );
  }
}
