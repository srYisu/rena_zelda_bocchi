import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:rena_zelda_bocchi/src/memorama/juegoTerminado.dart';

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
  late List<MemoramaCard> _cards;
  MemoramaCard? _firstFlipped;
  bool _wait = false;
  int _intentos = 0;

  @override
  void initState() {
    super.initState();
    _cards = _generateCards();
  }

  List<MemoramaCard> _generateCards() {
    final items = <Map<String, dynamic>>[
      {'id': 'casa', 'image': Icons.house, 'word': 'Casa'},
      {'id': 'libro', 'image': Icons.book, 'word': 'Libro'},
      {'id': 'auto', 'image': Icons.directions_car, 'word': 'Auto'},
      {'id': 'sol', 'image': Icons.wb_sunny, 'word': 'Sol'},
      {'id': 'flor', 'image': Icons.local_florist, 'word': 'Flor'},
      {'id': 'estrella', 'image': Icons.star, 'word': 'Estrella'},
    ];

    final cards = <MemoramaCard>[];

    for (var item in items) {
      cards.add(
        MemoramaCard(
          id: item['id'],
          content: Icon(item['image'], size: 48, color: Colors.blue),
        ),
      );
      cards.add(
        MemoramaCard(
          id: item['id'],
          content: Center(
            child: Text(
              item['word'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
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
          Future.delayed(const Duration(milliseconds: 800), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GameOverScreen(intentos: _intentos),
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
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          "Intentos: $_intentos",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
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
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        "?",
                        style: TextStyle(fontSize: 32, color: Colors.white),
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
          ),
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
