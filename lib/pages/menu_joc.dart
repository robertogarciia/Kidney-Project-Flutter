import 'package:flutter/material.dart';
import 'package:kidneyproject/components/btn_general.dart';
import 'package:kidneyproject/pages/RankingPage.dart';
import 'package:kidneyproject/pages/menu_principal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/pages/trivial_game.dart';
import 'package:kidneyproject/pages/trivial_game_no_habilitats.dart';

class MenuJoc extends StatefulWidget {
  final String userId;

  const MenuJoc({Key? key, required this.userId}) : super(key: key);

  @override
  _MenuJocState createState() => _MenuJocState();
}

class _MenuJocState extends State<MenuJoc> {
  int coins = 0;
  int points = 0;
  int pointsNoHabilitats = 0;
  int maxPuntuacion = 0;
  int maxPuntuacionNoHabilitats = 0;

  Future<void> _fetchCoinsAndPoints() async {
    try {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('trivial')
          .doc('datos')
          .get();

      setState(() {
        coins = userData['coins'] ?? 0;
        points = userData['points'] ?? 0;
        pointsNoHabilitats = userData['pointsNoHabilitats'] ?? 0;
        maxPuntuacion = userData['maxPuntuacion'] ?? 0;
        maxPuntuacionNoHabilitats = userData['maxPuntuacionNoHabilitats'] ?? 0;
      });
    } catch (error) {
      print('Error al obtener los datos del usuario: $error');
    }
  }

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void navigateBackToMenu(BuildContext context) {
    Navigator.pop(context); // Volver al menú principal
  }

  @override
  void initState() {
    super.initState();
    _fetchCoinsAndPoints();
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () =>
            navigateToPage(context, MenuPrincipal(userId: widget.userId)),
      ),
      actions: [
        IconButton(
          icon: Image.asset('lib/images/ranking.png', width: 50, height: 50),
          onPressed: () {
            navigateToPage(context, RankingPage(userId: widget.userId));
          },
        ),
      ],
      backgroundColor: const Color.fromRGBO(66, 61, 242, 1.0),
      title: const Text(
        "Menú de Joc",
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 16),

              // Resto del contenido
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Tipus de Joc",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(66, 61, 242, 1.0),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/images/coin.png',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$coins',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Última puntuació amb habilitats: $points',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Última puntuació sense habilitats: $pointsNoHabilitats',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              GestureDetector(
                onTap: () {
                  navigateToPage(context, TrivialPage(userId: widget.userId));
                },
                child: Container(
                  width: double.infinity,
                  height: 80,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.teal,
                    image: const DecorationImage(
                      image: AssetImage('lib/images/joystick_background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Joc amb habilitats',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              GestureDetector(
                onTap: () {
                  navigateToPage(context,
                      TrivialPageNoHabilitats(userId: widget.userId));
                },
                child: Container(
                  width: double.infinity,
                  height: 80,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.orange,
                    image: const DecorationImage(
                      image: AssetImage('lib/images/brain_background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Joc sense habilitats',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // Máximas puntuaciones con el mismo diseño
              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Max. puntuació amb habilitats: $maxPuntuacion',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Max. puntuació sense habilitats: $maxPuntuacionNoHabilitats',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}