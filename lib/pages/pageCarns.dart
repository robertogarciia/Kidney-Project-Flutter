import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kidneyproject/pages/detallPage.dart';

class pageCarns extends StatefulWidget {
  final String userId;
  final String tipusC;

  const pageCarns({Key? key, required this.userId, required this.tipusC})
      : super(key: key);

  @override
  _pageCarnsState createState() => _pageCarnsState();
}

class _pageCarnsState extends State<pageCarns> {
  Future<String> _getDownloadUrl(String path) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(path);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error al obtener la URL de descarga: $e");
      return ""; // Devolver un string vacío si hay un error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carns Disponibles'),
        backgroundColor: Colors.greenAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Dietes').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Ocurrió un error.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay datos disponibles.'));
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6.0,
              mainAxisSpacing: 6.0,
              childAspectRatio: 1,
            ),
            padding: const EdgeInsets.all(20.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> dieta =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              String? imageUrl = dieta['imageUrl'];

              return FutureBuilder<String>(
                future: _getDownloadUrl(imageUrl ?? ''),
                builder: (context, AsyncSnapshot<String> urlSnapshot) {
                  if (!urlSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  String imageUrl = urlSnapshot.data ?? '';
                  int puntuacion = (dieta['Puntuació'] != null &&
                          dieta['Puntuació'][widget.tipusC] != null)
                      ? dieta['Puntuació'][widget.tipusC]
                      : 0;

                  return GestureDetector(
                    onTap: () {
                      // Navegar a la página de detalles
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => detallPage(
                            nombre: dieta['Nom'] ?? 'Sin nombre',
                            descripcion:
                                dieta['Descripció'] ?? 'Sin descripción',
                            imageUrl: imageUrl,
                            puntuacion: puntuacion,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.greenAccent,
                          width: 3.0,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : const Icon(Icons.image_not_supported,
                                      size: 30),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              dieta['Nom'] ?? 'Sin nombre',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
