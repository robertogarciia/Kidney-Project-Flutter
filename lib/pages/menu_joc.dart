import 'package:flutter/material.dart';
import 'package:kidneyproject/components/btn_general.dart';
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
      });
    } catch (error) {
      print('Error al obtener las monedas: $error');
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
          onPressed: () => navigateToPage(context, MenuPrincipal(userId: widget.userId)),
        ),
        backgroundColor: const Color.fromRGBO(66, 61, 242, 1.0),
        title: const Text(
          "Menú de Joc",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 90),

                const Text(
                  "Tipus de Joc",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(66, 61, 242, 1.0),
                  ),
                ),
                const SizedBox(height: 20),

                // Mostrar las monedas obtenidas
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
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
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Mostrar la puntuación obtenida
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Última puntuació: $points',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Botón para "Joc amb habilitats" más grande
                GestureDetector(
                  onTap: () {
                    navigateToPage(context, TrivialPage(userId: widget.userId));
                  },
                  child: Container(
                    width: double.infinity,
                    height: 80,  // Aumento la altura del botón
                    padding: const EdgeInsets.all(20), // Aumento el padding
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.teal, // Color base en caso de que la imagen falle
                      image: DecorationImage(
                        image: AssetImage('lib/images/joystick_background.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Joc amb habilitats',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26, // Aumento el tamaño de la fuente
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Botón para "Joc sense habilitats" más grande
                GestureDetector(
                  onTap: () {
                    navigateToPage(
                        context, TrivialPageNoHabilitats(userId: widget.userId));
                  },
                  child: Container(
                    width: double.infinity,
                    height: 80,  // Aumento la altura del botón
                    padding: const EdgeInsets.all(20), // Aumento el padding
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.orange, // Color base en caso de que la imagen falle
                      image: DecorationImage(
                        image: AssetImage('lib/images/brain_background.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Joc sense habilitats',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26, // Aumento el tamaño de la fuente
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
