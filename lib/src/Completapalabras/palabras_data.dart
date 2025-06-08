// palabras_data.dart

class Palabra {
  final String incompleta;
  final List<String> opciones;
  final String correcta;

  Palabra(this.incompleta, this.opciones, this.correcta);
}

class BancoPalabras {
  static List<Palabra> obtenerPalabras() {
    return [
      Palabra("GA__", ["TO", "LL", "ZO"], "TO"), // GATO (GA + TO)
      Palabra("PA__", ["TO", "PO", "ZO"], "TO"), // PATO (PA + TO)
      Palabra("PE__", ["ZO", "LO", "ÑO"], "RO"), // PERRO (PE + RO)
      Palabra("CO__JO", [
        "NE",
        "LA",
        "SA",
      ], "NE"), // CONEJO (CO + NE) *opción más corta*
      Palabra("CA___", ["RRO", "LPO", "MFO"], "RRO"), // CARRO (CA + RRO)
      Palabra("SO_", ["L", "N", "R"], "L"), // SOL (SO + L)
      Palabra("ME__", ["SA", "LA", "CA"], "SA"), // MESA (ME + SA)
      Palabra("CA__", ["SA", "LA", "ZA"], "SA"), // CASA (CA + SA)
      Palabra("LU__", ["Z", "S", "N"], "Z"), // LUZ (LU + Z)
      Palabra("RE__", ["LO", "LA", "SA"], "LO"), // RELOJ (RE + LO)
      Palabra("MAN____", [
        "ZANA",
        "DANA",
        "TANA",
      ], "ZANA"), // MANZANA (MAN + ZANA)
      Palabra("PI__", ["ÑA", "SA", "MA"], "ÑA"), // PIÑA (PI + ÑA)
      Palabra("U__", ["VA", "MA", "LA"], "VA"), // UVA (U + VA)
      Palabra("CO___", ["RRE", "TA", "MERA"], "RRE"), // CORRER (CO + RRER)
      Palabra("JU___", ["GAR", "MAR", "SAR"], "GAR"), // JUGAR (JU + GAR)
      Palabra("CA____", ["NTAR", "MISA", "LOTE"], "NTAR"), // CANTAR (CA + NTAR)
      Palabra("PEN___", ["SAR", "PAR", "CAR"], "SAR"), // PENSAR (PEN + SAR)
      Palabra("BA___", ["LON", "RIN", "LAR"], "LON"), // BALÓN (BA + LON)
      Palabra("PE___", ["SAR", "CON", "LOR"], "SAR"), // SAR (PE + SAR)
    ];
  }
}
