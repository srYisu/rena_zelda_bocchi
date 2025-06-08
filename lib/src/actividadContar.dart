import 'package:flutter/material.dart';
import 'package:rena_zelda_bocchi/src/memorama/pantallaJuego.dart';
import 'package:rena_zelda_bocchi/src/puertas/juego_puertas.dart';
import 'package:rena_zelda_bocchi/src/Juegocontar/pares.dart';
import 'package:rena_zelda_bocchi/src/Juegocontar/juego_contar.dart';

class Actividadimagen extends StatelessWidget {
  const Actividadimagen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 800;
        final double cardWidth = isLargeScreen ? 260 : 180;
        final double cardHeight = isLargeScreen ? 280 : 220;

        return Stack(
          children: [
            // Fondo
            SizedBox.expand(
              child: Image.asset(
                'assets/images/FondoMenu.png',
                fit: BoxFit.cover,
              ),
            ),

            // Contenido
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: isLargeScreen ? 100 : 40),
                child: Column(
                  children: [
                    const Text(
                      '¡Elige una actividad!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.count(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: cardWidth / cardHeight,
                        children: _buildCards(context, cardWidth, cardHeight),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildCards(BuildContext context, double ancho, double alto) {
    return [
      ActividadCard(
        imagen: 'assets/images/HormigasYNumeros.png',
        texto: 'Contar',
        ancho: ancho,
        alto: alto,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ContarJuego()),
          );
        },
      ),
      ActividadCard(
        imagen: 'assets/images/Hormigas.png',
        texto: 'Memorama',
        ancho: ancho,
        alto: alto,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MemoramaGame()),
          );
        },
      ),
      ActividadCard(
        imagen: 'assets/images/HormigasYNumeros.png',
        texto: 'Puertas gramaticales',
        ancho: ancho,
        alto: alto,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JuegoPantalla()),
          );
        },
      ),
      ActividadCard(
        imagen: 'assets/images/Hormigas.png',
        texto: 'Memorama 2',
        ancho: ancho,
        alto: alto,
        onTap: () {},
      ),
      ActividadCard(
        imagen: 'assets/images/HormigasYNumeros.png',
        texto: 'Contar 3',
        ancho: ancho,
        alto: alto,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EmparejarVisual()),
          );
        },
      ),
      ActividadCard(
        imagen: 'assets/images/Hormigas.png',
        texto: 'Memorama 3',
        ancho: ancho,
        alto: alto,
        onTap: () {},
      ),
    ];
  }
}

class ActividadCard extends StatelessWidget {
  final String imagen;
  final String texto;
  final double ancho;
  final double alto;
  final VoidCallback onTap;

  const ActividadCard({
    super.key,
    required this.imagen,
    required this.texto,
    required this.onTap,
    required this.ancho,
    required this.alto,
  });

  @override
  Widget build(BuildContext context) {
    final double imagenSize = ancho - 50;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: ancho,
        height: alto, // <-- Aquí fijamos la altura total
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: imagenSize,
              height: imagenSize,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF05D090), Color(0xFF026A49)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(imagen, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                texto,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
