import 'package:flutter/material.dart';
import 'package:rena_zelda_bocchi/src/Completapalabras/completa.dart';
import 'package:rena_zelda_bocchi/src/Juegocontar/juego_contar.dart';
import 'package:rena_zelda_bocchi/src/Juegocontar/pares.dart';
import 'package:rena_zelda_bocchi/src/Juegocontar/sumas.dart';
import 'package:rena_zelda_bocchi/src/actividadContar.dart';
import 'package:rena_zelda_bocchi/src/memorama/pantallaJuego.dart';
import 'package:rena_zelda_bocchi/src/puertas/juego_puertas.dart';
import 'package:rive/rive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GameOverScreen extends StatelessWidget {
  final int levelId;
  final double estrellas;

  const GameOverScreen({super.key, required this.levelId, required this.estrellas});

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
    String message = "";
    if (estrellas == 3){
      message = "¡Excelente trabajo!";
    }else if (estrellas == 2){
      message = "¡Buen trabajo!";
    }else if (estrellas == 1){
      message = "¡Puedes hacerlo mejor!";
    }else{
      message = "¡Inténtalo de nuevo!";}
    // Llama a la función al construir el widget
    _guardarProgreso(estrellas);

    return Scaffold(
  body: Stack(
    children: [
      Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/fondoJuegoTerminado.png'),
      fit: BoxFit.cover,
    ),
  ),
),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Text(message, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Widget nextGame;
                switch (levelId) {
                  case 1:
                    nextGame = const MemoramaGame();
                    break;
                  case 2:
                    nextGame = JuegoPantalla();
                    break;
                  case 3:
                    nextGame = ContarJuego();
                    break;
                  case 4:
                    nextGame = CompletarPalabraApp();
                    break;
                  case 5:
                    nextGame = EmparejarVisual();
                    break;
                  case 6:
                    nextGame = SumasApp();
                    break;
                  default:
                    nextGame = const MemoramaGame();
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => nextGame),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //const Text("Volver a jugar", style: TextStyle(fontSize: 20)),
                 // const SizedBox(height: 10),
                  const Icon(Icons.loop, size: 50, color: Colors.blue,),
                ],
              )
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => Actividadimagen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: const Icon(Icons.close, color: Colors.red,),
            ),
          ],
        ),
      ),
    ],
  ),
);
  }
}