import 'package:flutter/material.dart';
import 'package:rena_zelda_bocchi/src/memorama/pantallaJuego.dart';
import 'package:rena_zelda_bocchi/src/puertas/juego_puertas.dart';
import 'package:rive/rive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GameOverScreen extends StatelessWidget {
  final int intentos;
  final int levelId;

  const GameOverScreen({super.key, required this.intentos, required this.levelId});

Future<void> _guardarProgreso(double estrellas) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    print("Usuario no autenticado");
    return;
  }


  try {
    // Paso 1: Leer el progreso existente
    final existing = await supabase
        .from('progress')
        .select('stars')
        .eq('user_id', user.id)
        .eq('level_id', levelId)
        .maybeSingle();

    final existingStars = existing?['stars'] ?? 0;

    if (estrellas > existingStars) {
      await supabase.from('progress').upsert(
        {
          'user_id': user.id, // CORREGIDO: usar user.id, no user completo
          'level_id': levelId,
          'stars': estrellas.toInt(), // Guarda como entero
        },
        onConflict: 'user_id, level_id' // CORREGIDO: usar como parámetro de upsert
      );

      print("✅ Progreso actualizado: ${estrellas.toInt()} estrellas");
    } else {
      print("ℹ️ Progreso no actualizado (ya tenía igual o más estrellas)");
    }
  } catch (e) {
    print("❌ Error al guardar progreso: $e");
  }
}



  @override
  Widget build(BuildContext context) {
    String message = "¡Buen intento!";
    double estrellas = 0;

    switch(levelId){
      case 1:
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
    }

    // Llama a la función al construir el widget
    _guardarProgreso(estrellas);

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
                    input?.change(estrellas);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MemoramaGame()),
                );
              },
              child: const Text("Jugar de nuevo"),
            ),
          ],
        ),
      ),
    );
  }
}
