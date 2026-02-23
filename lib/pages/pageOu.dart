import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/pages/cestaPage.dart';
import 'package:kidneyproject/pages/detallPage.dart';

class pageOu extends StatefulWidget {
  final String userId;
  final String tipusC;

  const pageOu({
    Key? key,
    required this.userId,
    required this.tipusC,
  }) : super(key: key);

  @override
  _pageOuState createState() => _pageOuState();
}

class _pageOuState extends State<pageOu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ous Disponibles'),
        backgroundColor: Colors.greenAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => cestaPage(
                    userId: widget.userId,
                    tipusC: widget.tipusC,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Dietes')
            .where('Categoria', isEqualTo: 'Ou')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Ocurrió un error.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay datos disponibles.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6.0,
              mainAxisSpacing: 6.0,
              childAspectRatio: 1,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> dieta =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              // Limpiar URL para evitar saltos y espacios invisibles
              String imageUrl = (dieta['ImageUrl'] ?? '')
                  .replaceAll('\n', '')
                  .replaceAll(' ', '')
                  .trim();

              int puntuacion = (dieta['Puntuació'] != null &&
                      dieta['Puntuació'][widget.tipusC] != null)
                  ? dieta['Puntuació'][widget.tipusC]
                  : 0;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => detallPage(
                        nombre: dieta['Nom'] ?? 'Sin nombre',
                        descripcion: dieta['Descripció'] ?? 'Sin descripción',
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
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    print("ERROR REAL: $error");
                                    return const Icon(
                                      Icons.broken_image,
                                      size: 40,
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                ),
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
      ),
    );
  }
}
