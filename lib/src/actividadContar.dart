import 'package:flutter/material.dart';
import 'package:rena_zelda_bocchi/src/memorama/pantallaJuego.dart';
import 'package:rena_zelda_bocchi/src/puertas/juego_puertas.dart';
import 'package:rena_zelda_bocchi/src/Juegocontar/pares.dart';
import 'package:rena_zelda_bocchi/src/Juegocontar/juego_contar.dart';
import 'package:rena_zelda_bocchi/src/Juegocontar/sumas.dart';
import 'package:rena_zelda_bocchi/src/Completapalabras/completa.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart'; // Asegúrate de importar esto
import 'package:flutter_tts/flutter_tts.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
// ...existing code...

class Actividadimagen extends StatefulWidget {
  const Actividadimagen({super.key});

  @override
  State<Actividadimagen> createState() => _ActividadimagenState();
}

class _ActividadimagenState extends State<Actividadimagen>
    with WidgetsBindingObserver, RouteAware {
  late Future<Map<int, int>> _progresoFuture;

  @override
  void initState() {
    super.initState();
    _progresoFuture = _cargarProgreso();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Cuando la app vuelve a estar en primer plano, recarga el progreso
    if (state == AppLifecycleState.resumed) {
      _refreshProgreso();
    }
  }

  @override
  void didPopNext() {
    // Se llama cuando regresas a este widget desde otra ruta (por ejemplo, usando el botón atrás del teléfono)
    _refreshProgreso();
  }

  Future<Map<int, int>> _cargarProgreso() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return {};
    final data = await supabase
        .from('progress')
        .select('level_id, stars')
        .eq('user_id', user.id);
    final Map<int, int> progreso = {};
    for (final row in data) {
      progreso[row['level_id'] as int] = row['stars'] as int;
    }
    return progreso;
  }

  void _refreshProgreso() {
    setState(() {
      _progresoFuture = _cargarProgreso();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<int, int>>(
      future: _progresoFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final progreso = snapshot.data!;
        return LayoutBuilder(
          builder: (context, constraints) {
            final isLargeScreen = constraints.maxWidth >= 800;
            final crossAxisCount = isLargeScreen ? 3 : 2;
            final double cardWidth = isLargeScreen ? 220 : 160;
            final double cardHeight = isLargeScreen ? 240 : 200;

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
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        const Text(
                          '¡Elige una actividad!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: LayoutBuilder(
                                builder: (context, innerConstraints) {
                                  final items = _buildCards(
                                    context,
                                    cardWidth,
                                    cardHeight,
                                    progreso,
                                  );
                                  final itemHeightWithSpacing = cardHeight + 20;
                                  final rows =
                                      (items.length / crossAxisCount).ceil();
                                  final totalHeightNeeded =
                                      rows * itemHeightWithSpacing + 20;

                                  if (totalHeightNeeded <
                                      innerConstraints.maxHeight) {
                                    // Caben en pantalla, no usar scroll
                                    return Wrap(
                                      spacing: 20,
                                      runSpacing: 20,
                                      alignment: WrapAlignment.center,
                                      children: items,
                                    );
                                  } else {
                                    // Usar GridView con scroll
                                    return GridView.count(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 20,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      childAspectRatio: cardWidth / cardHeight,
                                      children: items,
                                    );
                                  }
                                },
                              ),
                            ),
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
      },
    );
  }

  List<Widget> _buildCards(
    BuildContext context,
    double ancho,
    double alto,
    Map<int, int> progreso,
  ) {
    final cards = [
      {
        'imagen': 'assets/images/IconoContar.png',
        'texto': 'Contar',
        'levelId': 3,
        'onTap': () => _navigateAndRefresh(context, ContarJuego()),
      },
      {
        'imagen': 'assets/images/IconoMemorama.png',
        'texto': 'Memorama',
        'levelId': 1,
        'onTap': () => _navigateAndRefresh(context, const MemoramaGame()),
      },
      {
        'imagen': 'assets/images/IconoPuertas.png',
        'texto': 'Puertas\ngramaticales',
        'levelId': 2,
        'onTap': () => _navigateAndRefresh(context, JuegoPantalla()),
      },
      {
        'imagen': 'assets/images/IconoSumando.png',
        'texto': 'Sumando',
        'levelId': 6,
        'onTap': () => _navigateAndRefresh(context, SumasApp()),
      },
      {
        'imagen': 'assets/images/IconoPares.png',
        'texto': 'Pares',
        'levelId': 5,
        'onTap': () => _navigateAndRefresh(context, EmparejarVisual()),
      },
      {
        'imagen': 'assets/images/IconoSilabas.png',
        'texto': 'Jugando con\nsilabas',
        'levelId': 4,
        'onTap': () => _navigateAndRefresh(context, CompletarPalabraApp()),
      },
    ];

    return cards.map((card) {
      final estrellas = progreso[card['levelId']] ?? 0;
      return ActividadCard(
        imagen: card['imagen'] as String,
        texto: card['texto'] as String,
        ancho: ancho,
        alto: alto,
        onTap: card['onTap'] as VoidCallback,
        estrellas: estrellas,
      );
    }).toList();
  }

  void _navigateAndRefresh(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page)).then(
      (_) {
        _refreshProgreso();
      },
    );
  }
}

// ...existing code...
class ActividadCard extends StatelessWidget {
  final String imagen;
  final String texto;
  final double ancho;
  final double alto;
  final VoidCallback onTap;
  final int estrellas; // ⭐️ Nuevo parámetro

  const ActividadCard({
    super.key,
    required this.imagen,
    required this.texto,
    required this.onTap,
    required this.ancho,
    required this.alto,
    this.estrellas = 0,
  });

  @override
  Widget build(BuildContext context) {
    final double imagenSize = ancho - 40;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: ancho,
        height: alto,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Card visual
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(height: 20), // Espacio para las estrellas
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
                    child: SizedBox(
                      height: 40, // o 50 si quieres más espacio para 2 líneas
                      child: Text(
                        texto,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: ancho > 200 ? 20 : 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Estrellas en arco, por delante y fuera del card si es necesario
            Positioned(
              top: 3, // Puedes ajustar este valor para que sobresalga más
              left: 0,
              right: 0,
              child: SizedBox(
                height: 40,
                child: CustomPaint(
                  size: Size(ancho, 40),
                  painter: ArcStarsPainter(estrellas: estrellas),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dibuja 3 estrellas en arco, iluminando según el progreso
class ArcStarsPainter extends CustomPainter {
  final int estrellas;
  ArcStarsPainter({required this.estrellas});

  @override
  void paint(Canvas canvas, Size size) {
    const double starSize = 50;
    final Paint paint = Paint();
    final double centerX = size.width / 2;
    final double radius = size.width / 2.2;

    // Ángulos para 3 estrellas en arco (radianes)
    final angles = [-0.9, 0, 0.9];

    for (int i = 0; i < 3; i++) {
      final angle = angles[i];
      final dx = centerX + radius * Math.sin(angle);
      final dy = 12 + radius * (1 - Math.cos(angle)) * 0.6;

      paint.color = i < estrellas ? Colors.amber : Colors.grey.shade400;
      _drawStar(canvas, Offset(dx, dy), starSize, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final Path path = Path();
    const int points = 5;
    final double r = size / 2;
    final double r2 = r * 0.5;
    for (int i = 0; i < points * 2; i++) {
      final isEven = i % 2 == 0;
      final double radius = isEven ? r : r2;
      final double angle = (i * Math.pi / points) - Math.pi / 2;
      final double x = center.dx + radius * Math.cos(angle);
      final double y = center.dy + radius * Math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
