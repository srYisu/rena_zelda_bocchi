import 'package:flutter/material.dart';
import 'dart:math';

class FlipCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: isFlipped ? 1 : 0),
      duration: duration,
      builder: (context, value, child) {
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
                    child: back,
                  )
                  : front,
        );
      },
    );
  }
}
