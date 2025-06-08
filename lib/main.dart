import 'package:flutter/material.dart';
import 'package:rena_zelda_bocchi/src/actividadContar.dart';
import 'package:rena_zelda_bocchi/src/inicioSesion.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://fsustbitgannihkyzewg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZzdXN0Yml0Z2Fubmloa3l6ZXdnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY1NTQ4MzgsImV4cCI6MjA2MjEzMDgzOH0._5Pfs5XjzWAvizS-a8jxGIc1TvOd-XRwhumYM4t5jvk',
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Iniciosesion(), // Ya no necesitas el fondo aquí
      ),
    );
  }
}
