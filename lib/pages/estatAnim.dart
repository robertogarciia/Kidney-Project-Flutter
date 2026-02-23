import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/pages/graficaEstatAnim.dart';
import 'package:kidneyproject/pages/menu_principal.dart';

class EstatAnim extends StatefulWidget {
  final String userId;

  const EstatAnim({Key? key, required this.userId}) : super(key: key);

  @override
  _EstatAnimState createState() => _EstatAnimState();
}

class _EstatAnimState extends State<EstatAnim> {
  final Map<String, String> images = {
    'assets/images/caraFeliz.png': 'Content/a',
    'assets/images/caraNormal.png': 'Neutral',
    'assets/images/caraTriste.png': 'Trist/a'
  };
  bool mostrarImagen = false;

  void saveEmotion(String emotion) async {
    try {
      setState(() {
        mostrarImagen = true;
      });

      final userRef =
          FirebaseFirestore.instance.collection('Usuarios').doc(widget.userId);

      // Sumar coins
      DocumentReference datosRef = FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('trivial')
          .doc('datos');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot datosSnapshot = await transaction.get(datosRef);

        if (!datosSnapshot.exists) {
          transaction.set(datosRef, {'coins': 50});
        } else {
          int coinsActuales = datosSnapshot.get('coins') ?? 0;
          transaction.update(datosRef, {'coins': coinsActuales + 50});
        }
      });

      // Guardar emoción
      await userRef.collection('estatAnim').add({
        'Estat': emotion,
        'Data': FieldValue.serverTimestamp(),
      });

      // Esperar 2 segundos y luego navegar
      await Future.delayed(Duration(seconds: 1));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MenuPrincipal(userId: widget.userId)),
        );
      }
    } catch (e) {
      print('Error saving emotion or updating points: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 161, 196, 249),
      appBar: AppBar(
        title: const Text(
          'Com et sents avui?',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        bool esMovil = constraints.maxWidth < 600;

                        return esMovil
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: images.entries.map((entry) {
                                  String imagePath = entry.key;
                                  String emotion = entry.value;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: GestureDetector(
                                      onTap: () => saveEmotion(emotion),
                                      child: Card(
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Container(
                                          width: 220,
                                          height: 160,
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(imagePath,
                                                  width: 60, height: 60),
                                              const SizedBox(height: 10),
                                              Text(
                                                emotion.toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blueAccent,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: images.entries.map((entry) {
                                  String imagePath = entry.key;
                                  String emotion = entry.value;

                                  return GestureDetector(
                                    onTap: () => saveEmotion(emotion),
                                    child: Card(
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Container(
                                        width: 200,
                                        height: 220,
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(imagePath,
                                                width: 50, height: 50),
                                            const SizedBox(height: 8),
                                            Text(
                                              emotion.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueAccent,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (mostrarImagen)
            Container(
              color: Colors.black.withOpacity(0.5),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/+50Puntos.png',
                width: 200,
                height: 200,
              ),
            ),
        ],
      ),
    );
  }
}
