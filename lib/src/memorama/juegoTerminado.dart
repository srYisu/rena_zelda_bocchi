import 'package:flutter/material.dart';
import 'package:rena_zelda_bocchi/src/memorama/pantallaJuego.dart';
import 'package:rive/rive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GameOverScreen extends StatefulWidget {
  final int levelId;
  final double estrellas;

  const GameOverScreen({super.key, required this.levelId, required this.estrellas});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  SMINumber? _input;
  Artboard? _artboard;
  bool _delayDone = false;

  @override
  void initState() {
    super.initState();
    _guardarProgresoYAnimar();
  }

  Future<void> _guardarProgresoYAnimar() async {
    await _guardarProgreso(widget.estrellas);
    await Future.delayed(const Duration(seconds: 1));
    _delayDone = true;
    if (_input != null) {
      _input!.change(widget.estrellas);
    }
  }

  Future<void> _guardarProgreso(double estrellas) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print("Usuario no autenticado");
      return;
    }

    try {
      final existing = await supabase
          .from('progress')
          .select('stars')
          .eq('user_id', user.id)
          .eq('level_id', widget.levelId)
          .maybeSingle();

      final existingStars = existing?['stars'] ?? 0;

      if (estrellas > existingStars) {
        await supabase.from('progress').upsert(
          {
            'user_id': user.id,
            'level_id': widget.levelId,
            'stars': estrellas.toInt(),
          },
          onConflict: 'user_id, level_id'
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
    if (widget.estrellas == 3) {
      message = "¡Excelente trabajo!";
    } else if (widget.estrellas == 2) {
      message = "¡Buen trabajo!";
    } else if (widget.estrellas == 1) {
      message = "¡Puedes hacerlo mejor!";
    } else {
      message = "¡Inténtalo de nuevo!";
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Resultado")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                    _input = controller.findInput<double>('nEstrellas') as SMINumber?;
                    // Si el delay ya terminó, dispara la animación ahora
                    if (_delayDone && _input != null) {
                      _input!.change(widget.estrellas);
                    }
                  }
                  _artboard = artboard;
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