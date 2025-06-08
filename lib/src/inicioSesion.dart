import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rena_zelda_bocchi/src/actividadContar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Iniciosesion extends StatefulWidget {
  @override
  _Iniciosesion createState() => _Iniciosesion();
}

class _Iniciosesion extends State<Iniciosesion> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'], 
    serverClientId: '347514460071-j2hnsqvnir7bb2jkf4lor34ola3gj9s7.apps.googleusercontent.com'
  );
  String? userId;
  String? nombre;

  @override
  void initState() {
    super.initState();
    _autoLogin();
  }

  Future<void> _autoLogin() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("❌ Usuario canceló el inicio");
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        print("❌ No se pudo obtener el token de Google");
        return;
      }

      final res = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      final user = res.user;
      if (user != null) {
        print('✅ Usuario conectado a Supabase: ${user.email}');
        setState(() {
          userId = user.id;
          nombre = googleUser.displayName ?? "Niño";
        });
      }
    } catch (e) {
      print("⚠️ Error en login: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Actividadimagen()
    );
  }
}