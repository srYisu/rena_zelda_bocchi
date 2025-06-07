import 'package:flutter/material.dart';
import 'package:rena_zelda_bocchi/src/memorama/pantallaJuego.dart';
import 'package:rena_zelda_bocchi/src/puertas/juego_puertas.dart';

class Actividadimagen extends StatelessWidget {
  const Actividadimagen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 800;
        final double cardWidth = isLargeScreen ? 260 : 200;
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

            // Contenido con SafeArea y scroll para evitar overflow
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: isLargeScreen ? 120 : 60),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                        const SizedBox(height: 30),

                        // Contenedor de tarjetas
                        SizedBox(
                          width: isLargeScreen ? 860 : double.infinity,
                          child: Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            alignment: WrapAlignment.center,
                            children: _buildCards(
                              context,
                              cardWidth,
                              cardHeight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
        onTap: () {},
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
        onTap: () {},
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
      child: Container(
        width: ancho,
        height: alto,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Container(
                  width: imagenSize,
                  height: imagenSize,
                  decoration: ShapeDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment(0.5, 0.0),
                      end: Alignment(0.5, 1.0),
                      colors: [Color(0xFF05D090), Color(0xFF026A49)],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: imagenSize,
                    height: imagenSize,
                    child: Image.asset(imagen, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    texto,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
