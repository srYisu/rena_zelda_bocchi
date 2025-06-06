import 'package:flutter/material.dart';
import 'package:rena_zelda_bocchi/src/memorama/pantallaJuego.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fsustbitgannihkyzewg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZzdXN0Yml0Z2Fubmloa3l6ZXdnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY1NTQ4MzgsImV4cCI6MjA2MjEzMDgzOH0._5Pfs5XjzWAvizS-a8jxGIc1TvOd-XRwhumYM4t5jvk',
  );

  // Inicia sesión con el usuario predeterminado
  await Supabase.instance.client.auth.signInWithPassword(
    email: 'sr.elyisus@gmail.com',
    password: '123',
  );

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
