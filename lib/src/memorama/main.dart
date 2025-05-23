import 'package:flutter/material.dart';
import 'package:rena_zelda_bocchi/src/memorama/pantallaJuego.dart';

void main() {
  runApp(PuertasApp());
}

class PuertasApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Juego de Puertas',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: MemoramaGame(),
    );
  }
}
