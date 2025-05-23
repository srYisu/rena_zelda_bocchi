import 'package:flutter/material.dart';

class Pregunta {
  final IconData icono;
  final String opcion1;
  final String opcion2;
  final String correcta;

  Pregunta({
    required this.icono,
    required this.opcion1,
    required this.opcion2,
    required this.correcta,
  });
}

class BancoPreguntas {
  final List<Pregunta> preguntas = [
    Pregunta(
      icono: Icons.pets,
      opcion1: 'Gato',
      opcion2: 'Perro',
      correcta: 'Perro',
    ),
    Pregunta(
      icono: Icons.directions_car,
      opcion1: 'Avión',
      opcion2: 'Auto',
      correcta: 'Auto',
    ),
    Pregunta(
      icono: Icons.apple,
      opcion1: 'Manzana',
      opcion2: 'Banana',
      correcta: 'Manzana',
    ),
    Pregunta(
      icono: Icons.cake,
      opcion1: 'Pastel',
      opcion2: 'Pan',
      correcta: 'Pastel',
    ),
    Pregunta(
      icono: Icons.phone_android,
      opcion1: 'Teléfono',
      opcion2: 'Reloj',
      correcta: 'Teléfono',
    ),

    Pregunta(
      icono: Icons.flight,
      opcion1: 'Avión',
      opcion2: 'Barco',
      correcta: 'Avión',
    ),
    Pregunta(
      icono: Icons.home,
      opcion1: 'Casa',
      opcion2: 'Edificio',
      correcta: 'Casa',
    ),
    Pregunta(
      icono: Icons.book,
      opcion1: 'Libro',
      opcion2: 'Cuaderno',
      correcta: 'Libro',
    ),
    Pregunta(
      icono: Icons.bike_scooter,
      opcion1: 'Moto',
      opcion2: 'Bicicleta',
      correcta: 'Moto',
    ),
    Pregunta(
      icono: Icons.local_cafe,
      opcion1: 'Té',
      opcion2: 'Café',
      correcta: 'Café',
    ),

    Pregunta(
      icono: Icons.brush,
      opcion1: 'Pincel',
      opcion2: 'Lápiz',
      correcta: 'Pincel',
    ),
    Pregunta(
      icono: Icons.computer,
      opcion1: 'Computadora',
      opcion2: 'Televisor',
      correcta: 'Computadora',
    ),
    Pregunta(
      icono: Icons.headset,
      opcion1: 'Audífonos',
      opcion2: 'Micrófono',
      correcta: 'Audífonos',
    ),
    Pregunta(
      icono: Icons.camera_alt,
      opcion1: 'Cámara',
      opcion2: 'Teléfono',
      correcta: 'Cámara',
    ),
    Pregunta(
      icono: Icons.watch,
      opcion1: 'Reloj',
      opcion2: 'Pulsera',
      correcta: 'Reloj',
    ),

    Pregunta(
      icono: Icons.local_fire_department,
      opcion1: 'Fuego',
      opcion2: 'Agua',
      correcta: 'Fuego',
    ),
    Pregunta(
      icono: Icons.star,
      opcion1: 'Estrella',
      opcion2: 'Sol',
      correcta: 'Estrella',
    ),
    Pregunta(
      icono: Icons.music_note,
      opcion1: 'Música',
      opcion2: 'Película',
      correcta: 'Música',
    ),
    Pregunta(
      icono: Icons.directions_bike,
      opcion1: 'Bicicleta',
      opcion2: 'Coche',
      correcta: 'Bicicleta',
    ),
    Pregunta(
      icono: Icons.local_florist,
      opcion1: 'Flor',
      opcion2: 'Árbol',
      correcta: 'Flor',
    ),

    Pregunta(
      icono: Icons.lightbulb,
      opcion1: 'Bombilla',
      opcion2: 'Lámpara',
      correcta: 'Bombilla',
    ),
    Pregunta(
      icono: Icons.directions_boat,
      opcion1: 'Barco',
      opcion2: 'Tren',
      correcta: 'Barco',
    ),
    Pregunta(
      icono: Icons.sports_soccer,
      opcion1: 'Fútbol',
      opcion2: 'Baloncesto',
      correcta: 'Fútbol',
    ),
    Pregunta(
      icono: Icons.kitchen,
      opcion1: 'Cocina',
      opcion2: 'Baño',
      correcta: 'Cocina',
    ),
    Pregunta(
      icono: Icons.local_hospital,
      opcion1: 'Hospital',
      opcion2: 'Farmacia',
      correcta: 'Hospital',
    ),

    Pregunta(
      icono: Icons.shopping_cart,
      opcion1: 'Carrito',
      opcion2: 'Bicicleta',
      correcta: 'Carrito',
    ),
    Pregunta(
      icono: Icons.school,
      opcion1: 'Escuela',
      opcion2: 'Biblioteca',
      correcta: 'Escuela',
    ),
    Pregunta(
      icono: Icons.umbrella,
      opcion1: 'Paraguas',
      opcion2: 'Sombrero',
      correcta: 'Paraguas',
    ),
    Pregunta(
      icono: Icons.pool,
      opcion1: 'Piscina',
      opcion2: 'Lago',
      correcta: 'Piscina',
    ),
    Pregunta(
      icono: Icons.spa,
      opcion1: 'Spa',
      opcion2: 'Parque',
      correcta: 'Spa',
    ),

    Pregunta(
      icono: Icons.local_pizza,
      opcion1: 'Pizza',
      opcion2: 'Hamburguesa',
      correcta: 'Pizza',
    ),
    Pregunta(
      icono: Icons.movie,
      opcion1: 'Película',
      opcion2: 'Música',
      correcta: 'Película',
    ),
  ];
}
