import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/pages/menu_principal.dart';

class EstatAnim extends StatefulWidget {
  final String userId;

  const EstatAnim({Key? key, required this.userId}) : super(key: key);

  @override
  _EstatAnimState createState() => _EstatAnimState();
}

class _EstatAnimState extends State<EstatAnim> {
  final Map<String, String> images = {
    'lib/images/caraFeliz.png': 'Content/a',
    'lib/images/caraNormal.png': 'Neutral',
    'lib/images/caraTriste.png': 'Trist/a'
  };

  void saveEmotion(String emotion) async {
    try {
      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('estatAnim')
          .add({'Estat': emotion, 'Data': FieldValue.serverTimestamp()});

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MenuPrincipal(userId: widget.userId)),
      );
    } catch (e) {
      print('Error saving emotion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 161, 196, 249),
      appBar: AppBar(
        title: const Text(
          'Com et sents avui?',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1.7,
                  mainAxisSpacing: 3,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  String imagePath = images.keys.elementAt(index);
                  String emotion = images.values.elementAt(index);
                  return GestureDetector(
                    onTap: () => saveEmotion(emotion),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(imagePath, width: 60, height: 60),
                            const SizedBox(height: 15),
                            Text(
                              emotion.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}