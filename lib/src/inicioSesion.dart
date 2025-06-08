import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rena_zelda_bocchi/src/actividadContar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Iniciosesion extends StatefulWidget {
  @override
  _Iniciosesion createState() => _Iniciosesion();
}

class _Iniciosesion extends State<Iniciosesion> {
  GoogleSignIn? _googleSignIn;

  String? userId;
  String? nombre;

@override
void initState() {
  super.initState();

  // 🔁 Espera cambios de sesión
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    final session = data.session;

    if (event == AuthChangeEvent.signedIn && session != null) {
      print('✅ Sesión restaurada desde redirect');
      setState(() {
        userId = session.user.id;
        nombre = session.user.userMetadata?['full_name'] ?? 'Niño';
      });
    }
  });

  // ⚠️ Solo autoLogin si no hay sesión activa
  final session = Supabase.instance.client.auth.currentSession;
  final user = Supabase.instance.client.auth.currentUser;

  if (session == null || user == null) {
    _autoLogin();
  } else {
    print('✅ Ya había sesión: ${user.email}');
    userId = user.id;
    nombre = user.userMetadata?['full_name'] ?? 'Niño';
  }
}


  Future<void> _autoLogin() async {
    try {
      if (kIsWeb) {
  final redirectUrl = Uri.base.origin + '/';
  await Supabase.instance.client.auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo: redirectUrl,
  );
  print("🔁 Redireccionando a login...");
  return;
}


      // 📱 Android / iOS: Usa GoogleSignIn
      _googleSignIn = GoogleSignIn(
        scopes: ['email'],
        serverClientId:
            '347514460071-j2hnsqvnir7bb2jkf4lor34ola3gj9s7.apps.googleusercontent.com', // Android OAuth
      );

      final googleUser = await _googleSignIn!.signIn();
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
      body: userId != null
          ? Actividadimagen()
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
