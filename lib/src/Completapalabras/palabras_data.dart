import 'package:flutter/material.dart';

class Palabra {
  final String incompleta;
  final List<String> opciones;
  final String correcta;
  final IconData icono;

  Palabra(this.incompleta, this.opciones, this.correcta, this.icono);
}

class BancoPalabras {
  static List<Palabra> obtenerPalabras() {
    return [
      Palabra("PA__", ["RO", "TA", "ÑO"], "TA", Icons.pets), // PERRO
      Palabra(
        "CA___",
        ["RRO", "LPO", "MFO"],
        "RRO",
        Icons.directions_car,
      ), // CARRO
      Palabra("SO_", ["L", "N", "R"], "L", Icons.wb_sunny), // SOL
      Palabra("ME__", ["SA", "LA", "CA"], "SA", Icons.table_bar), // MESA
      Palabra("CA__", ["SA", "LA", "BA"], "SA", Icons.house), // CASA
      Palabra("LU__", ["Z", "S", "N"], "Z", Icons.lightbulb), // LUZ
      Palabra("RE__", ["LOJ", "LAS", "CAS"], "LOJ", Icons.watch), // RELOJ
      Palabra(
        "MAN____",
        ["ZANA", "DANA", "TANA"],
        "ZANA",
        Icons.apple,
      ), // MANZANA
      Palabra("PI__", ["ZZA", "SA", "MA"], "ZZA", Icons.local_pizza), //
      Palabra(
        "CO___",
        ["RRE", "TA", "MERA"],
        "RRE",
        Icons.run_circle,
      ), // CORRER
      Palabra(
        "JU___",
        ["GAR", "MAR", "SAR"],
        "GAR",
        Icons.videogame_asset,
      ), // JUGAR
      Palabra("CA____", ["NTAR", "MIS", "LOTE"], "NTAR", Icons.mic), // CANTAR
      Palabra(
        "PEN___",
        ["SAR", "PAR", "CAR"],
        "SAR",
        Icons.psychology,
      ), // PENSAR
      Palabra(
        "BA___",
        ["LON", "RIN", "LAR"],
        "LON",
        Icons.sports_soccer,
      ), // BALÓN
    ];
  }
}
