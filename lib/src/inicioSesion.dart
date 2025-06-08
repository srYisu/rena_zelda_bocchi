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
  String? errorMsg; // <-- Para mostrar el error

  @override
  void initState() {
    super.initState();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        setState(() {
          userId = session.user.id;
          nombre = session.user.userMetadata?['full_name'] ?? 'Niño';
          errorMsg = null;
        });
      }
    });

    final session = Supabase.instance.client.auth.currentSession;
    final user = Supabase.instance.client.auth.currentUser;

    if (session == null || user == null) {
      _autoLogin();
    } else {
      userId = user.id;
      nombre = user.userMetadata?['full_name'] ?? 'Niño';
    }
  }

  Future<void> _autoLogin() async {
    setState(() {
      errorMsg = null;
    });
    try {
      if (kIsWeb) {
        final redirectUrl = Uri.base.origin + '/';
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: redirectUrl,
        );
        return;
      }

      _googleSignIn = GoogleSignIn(
        scopes: ['email'],
        serverClientId:
            '347514460071-j2hnsqvnir7bb2jkf4lor34ola3gj9s7.apps.googleusercontent.com',
      );

      final googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        setState(() {
          errorMsg = "El inicio de sesión fue cancelado.";
        });
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        setState(() {
          errorMsg = "No se pudo obtener el token de Google.";
        });
        return;
      }

      final res = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      final user = res.user;
      if (user != null) {
        setState(() {
          userId = user.id;
          nombre = googleUser.displayName ?? "Niño";
          errorMsg = null;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = "Ocurrió un error al iniciar sesión. Intenta de nuevo.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: userId != null
          ? Actividadimagen()
          : Center(
              child: errorMsg == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 60),
                        const SizedBox(height: 16),
                        Text(
                          errorMsg!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, color: Colors.red),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _autoLogin,
                          child: const Text("Reintentar"),
                        ),
                      ],
                    ),
            ),
    );
  }
}