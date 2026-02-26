import 'package:flutter/material.dart';
import 'package:kidneyproject/components/btn_general.dart';
import 'package:kidneyproject/pages/RankingPage.dart';
import 'package:kidneyproject/pages/menu_principal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/pages/trivial_game.dart';
import 'package:kidneyproject/pages/trivial_game_no_habilitats.dart';

import 'jocPacient.dart';

class MenuJoc extends StatefulWidget {
  final String userId;
  final bool isFamiliar;
  final String? relatedPatientId;

  const MenuJoc({
    Key? key,
    required this.userId,
    this.isFamiliar = false,
    this.relatedPatientId,
  }) : super(key: key);

  @override
  _MenuJocState createState() => _MenuJocState();
}

class _MenuJocState extends State<MenuJoc> {
  int coins = 0;
  int points = 0;
  int pointsNoHabilitats = 0;
  int maxPuntuacion = 0;
  int maxPuntuacionNoHabilitats = 0;
  late bool isFamiliar; // Valor recibido por navegacion
  late String? relatedPatientId; // Paciente relacionado recibido por navegacion
  bool isLoading = false; // No hace falta consultar tipo/relacion aqui

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> _fetchCoinsAndPoints() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final userData = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('trivial')
          .doc('datos')
          .get();

      final data = userData.data() as Map<String, dynamic>? ?? {};
      if (!mounted) return;
      setState(() {
        coins = _toInt(data['coins']);
        points = _toInt(data['points']);
        maxPuntuacion = _toInt(data['maxPuntuacion']);
        pointsNoHabilitats = _toInt(data['pointsNoHabilitats']);
        maxPuntuacionNoHabilitats = _toInt(data['maxPuntuacionNoHabilitats']);
        isLoading = false;
      });
    } catch (error) {
      print('Error al obtener los datos del usuario: $error');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> navigateToPage(BuildContext context, Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    await _fetchCoinsAndPoints();
  }

  void navigateBackToMenu(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    isFamiliar = widget.isFamiliar;
    relatedPatientId = widget.relatedPatientId;
    _fetchCoinsAndPoints(); // Obtenir  punts i monedes

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            await navigateToPage(
              context,
              MenuPrincipal(
                userId: widget.userId,
                isFamiliar: isFamiliar,
                relatedPatientId: relatedPatientId,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon:
                Image.asset('assets/images/ranking.png', width: 50, height: 50),
            onPressed: () async {
              await navigateToPage(context, RankingPage(
                  userId: widget.userId,
                  isFamiliar: isFamiliar,
                  relatedPatientId: relatedPatientId,
                ));
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

                // Mostrar las monedas
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
                            'assets/images/coin.png',
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

                // Botón para "Joc amb habilitats"
                GestureDetector(
                  onTap: () async {
                    await navigateToPage(context, TrivialPage(
                          userId: widget.userId,
                          isFamiliar: isFamiliar,
                          relatedPatientId: relatedPatientId,
                        ));
                  },
                  child: Container(
                    width: double.infinity,
                    height: 80,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.teal,
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

                // Botón para "Joc sense habilitats"
                GestureDetector(
                  onTap: () async {
                    await navigateToPage(context,
                        TrivialPageNoHabilitats(
                          userId: widget.userId,
                          isFamiliar: isFamiliar,
                          relatedPatientId: relatedPatientId,
                        ));
                  },
                  child: Container(
                    width: double.infinity,
                    height: 80,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.orange,
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

                const SizedBox(height: 40),
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
                // Mostrar puntuaciones
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events,
                          color: Colors.amber, size: 24),
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
                      const Icon(Icons.emoji_events,
                          color: Colors.amber, size: 24),
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

                if (isLoading)
                  Center(
                    child: CircularProgressIndicator(),
                  )

                // Botó per veure el pacient relacionat si es familiar
                else if (isFamiliar && relatedPatientId != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          if (relatedPatientId != null) {
                            // Navegar a la página jocPacient
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => jocPacient(
                                    relatedPatientId: relatedPatientId!),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(66, 61, 242, 1.0),
                          padding: EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 30.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          shadowColor: Colors.black.withOpacity(0.3),
                          elevation: 8, // Sombra más suave
                        ),
                        child: const Text(
                          'Veure Dades del Pacient',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
