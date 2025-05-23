import 'package:flutter/material.dart';

class Actividadimagen extends StatefulWidget {
  const Actividadimagen({super.key});

  @override
  State<Actividadimagen> createState() => _Actividadimagen();
}

class _Actividadimagen extends State<Actividadimagen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 162,
      height: 185,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(),
      child: Stack(
        children: [
          // Fondo con imagen
          Positioned(
            left: 19,
            top: 22,
            child: Container(
              width: 130,
              height: 130,
              decoration: ShapeDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.50, -0.00),
                  end: Alignment(0.50, 1.00),
                  colors: [Color(0xFF05D090), Color(0xFF026A49)],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Positioned(
            left: 25,
            top: 10,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Hormigas.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            left: 25,
            top: 152,
            child: SizedBox(
              width: 118,
              height: 33,
              child: Text(
                'Memorama',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 2,
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 70,
            child: Container(
              width: 150,
              height: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Numeros.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
//a