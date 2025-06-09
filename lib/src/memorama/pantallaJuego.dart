import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rena_zelda_bocchi/src/memorama/juegoTerminado.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';


// MODELO DE CARTA
class MemoramaCard {
  final String id;
  final Widget content;
  bool isMatched;
  bool isFlipped;

  MemoramaCard({
    required this.id,
    required this.content,
    this.isMatched = false,
    this.isFlipped = false,
  });
}


// JUEGO
class MemoramaGame extends StatefulWidget {
  const MemoramaGame({Key? key}) : super(key: key);

  @override
  State<MemoramaGame> createState() => _MemoramaGameState();
}

class _MemoramaGameState extends State<MemoramaGame> {
  final FlutterTts _flutterTts = FlutterTts();
  late List<MemoramaCard> _cards;
  MemoramaCard? _firstFlipped;
  bool _wait = false;
  int _intentos = 0;
  double estrellas = 0;

  @override
void initState() {
  super.initState();
  _initTts();
  _cards = _generateCards();
  _speak("Encuentra los pares");
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
  List<MemoramaCard> _generateCards() {
    final items = <Map<String, dynamic>>[
      {'id': 'gato', 'icon': MdiIcons.cat, 'word': 'Gato', 'color': const Color.fromARGB(255, 243, 115, 11)},
      {'id': 'perro', 'icon': MdiIcons.dog, 'word': 'Perro', 'color': const Color.fromARGB(255, 247, 173, 36)},
      {'id': 'oso', 'icon': MdiIcons.teddyBear, 'word': 'Oso', 'color': Colors.brown},
      {'id': 'dado', 'icon': MdiIcons.dice5, 'word': 'Dado', 'color': Colors.green},
      {'id': 'manzana', 'icon': MdiIcons.apple, 'word': 'Manzana', 'color': Colors.red},
      {'id': 'tijera', 'icon': Icons.content_cut, 'word': 'Tijera', 'color': Colors.pink},
      {'id': 'globo', 'icon': MdiIcons.balloon, 'word': 'Globo', 'color': Colors.red},
      {'id': 'luna', 'icon': MdiIcons.moonWaningCrescent, 'word': 'Luna', 'color': Colors.black},
      {'id': 'flor', 'icon': MdiIcons.flower, 'word': 'Flor', 'color': Colors.purple},
      {'id': 'corazon', 'icon': MdiIcons.heart, 'word': 'Corazón', 'color': Colors.pinkAccent},
      {'id': 'mariposa', 'icon': MdiIcons.butterfly, 'word': 'Mariposa', 'color': Colors.orange},
      {'id': 'pajaro', 'icon': MdiIcons.bird, 'word': 'Pájaro', 'color': Colors.lightBlue},
      {'id': 'pez', 'icon': MdiIcons.fish, 'word': 'Pez', 'color': Colors.teal},
      {'id': 'pino', 'icon': MdiIcons.pineTree, 'word': 'Pino', 'color': Colors.greenAccent},
    ];

  items.shuffle();
  final selected = items.take(6).toList();
    final cards = <MemoramaCard>[];

    for (var item in selected) {
      cards.add(
        MemoramaCard(
          id: item['id'],
          content: Icon(item['icon'], size: 48, color: item['color'] as Color?),
        ),
      );
      cards.add(
        MemoramaCard(
          id: item['id'],
          content: Center(
            child: Text(
              item['word'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: item['color'] as Color? ?? Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      );
    }

    cards.shuffle();
    return cards;
  }

  void _onCardTap(int index) async {
    if (_wait || _cards[index].isFlipped || _cards[index].isMatched) return;

    setState(() {
      _cards[index].isFlipped = true;
      final flippedCard = _cards[index];
if (flippedCard.content is Center && flippedCard.content is! Icon) {
  final textWidget = (flippedCard.content as Center).child;
  if (textWidget is Text) {
    _speak(textWidget.data ?? '');
  }
}
    });

    if (_firstFlipped == null) {
      _firstFlipped = _cards[index];
    } else {
      _wait = true;
      await Future.delayed(const Duration(milliseconds: 700));

      setState(() {
        _intentos++;
      });

      if (_firstFlipped!.id == _cards[index].id) {
        setState(() {
          _cards[index].isMatched = true;
          _firstFlipped!.isMatched = true;
        });

        if (_cards.every((card) => card.isMatched)) {
          if(_intentos <= 14){
            estrellas = 3;
          }
          else if(_intentos <= 18){
            estrellas = 2;
          }
          else if(_intentos <= 22){
            estrellas = 1;
          } else {
            estrellas = 0;
          }
          Future.delayed(const Duration(milliseconds: 800), () {
            Navigator.pushReplacement( 
              context,
              MaterialPageRoute(
                builder: (context) => GameOverScreen(levelId: 1, estrellas: estrellas ),
              ),
            );
          });
        }
      } else {
        setState(() {
          _cards[index].isFlipped = false;
          _firstFlipped!.isFlipped = false;
        });
      }

      _firstFlipped = null;
      _wait = false;
    }
  }

@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      Positioned.fill(
        child: Image.asset(
          'assets/images/fondoMemorama.png',
          fit: BoxFit.cover,
        ),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Text(
            "¡Encuentra las",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            "parejas¡",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 10),
          // ...existing code...
Expanded(
  child: LayoutBuilder(
    builder: (context, constraints) {
      // Cambia el número de columnas según el ancho
      int crossAxisCount = 3;
      if (constraints.maxWidth > 900) {
        crossAxisCount = 6;
      } else if (constraints.maxWidth > 600) {
        crossAxisCount = 4;
      }
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cards.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final card = _cards[index];
          return GestureDetector(
            onTap: () => _onCardTap(index),
            child: FlipCard(
              isFlipped: card.isFlipped || card.isMatched,
              front: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 56, 149, 224),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Image(
                    image: AssetImage('assets/images/globos.png'),
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              back: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: card.content,
              ),
            ),
          );
        },
      );
    },
  ),
),
// ...existing code...
        ],
      ),
    ],
  );
}
}
// FLIP CARD CON AUDIO
class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool isFlipped;
  final Duration duration;

  const FlipCard({
    Key? key,
    required this.front,
    required this.back,
    required this.isFlipped,
    this.duration = const Duration(milliseconds: 400),
  }) : super(key: key);

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> {
  final AudioPlayer _player = AudioPlayer();
  double _previousValue = 0;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _playFlipSound(double value) {
    if ((_previousValue < 0.5 && value >= 0.5) ||
        (_previousValue >= 0.5 && value < 0.5)) {
      _player.play(AssetSource('sounds/flip.mp3'));
    }
    _previousValue = value;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: widget.isFlipped ? 1 : 0),
      duration: widget.duration,
      builder: (context, value, child) {
        _playFlipSound(value);

        final angle = value * pi;
        final showBack = value >= 0.5;

        return Transform(
          alignment: Alignment.center,
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
          child:
              showBack
                  ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: widget.back,
                  )
                  : widget.front,
        );
      },
    );
  }
}
