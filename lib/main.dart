import 'package:flutter/material.dart';
import 'package:rena_zelda_bocchi/src/actividadContar.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Row(
                children: [
                  Actividadimagen()
                ],
              )
            ],
          )
        ),
      ),
    );
  }
}
