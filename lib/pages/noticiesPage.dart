import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/components/info_card.dart';
import 'noticiesPacient.dart';

class noticiesPage extends StatefulWidget {
  final String userId;
  final bool isFamiliar; // recibido desde menu_principal
  final String? relatedPatientId; // recibido desde menu_principal

  const noticiesPage({
    Key? key,
    required this.userId,
    this.isFamiliar = false,
    this.relatedPatientId,
  }) : super(key: key);

  @override
  _noticiesPageState createState() => _noticiesPageState();
}

class _noticiesPageState extends State<noticiesPage> {
  String? selectedCategory;
  String searchQuery = '';
  bool mostrarImagen = false;

  void resetFilter() {
    setState(() {
      selectedCategory = null;
      searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = widget.userId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD53D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.isFamiliar && widget.relatedPatientId != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => noticiesPacient(
                        relatedPatientId: widget.relatedPatientId!,
                      ),
                    ),
                  );
                },
                child: const Text('Veure notícies del meu pacient'),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Center(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 20),
                    const Text(
                      'Noticies',
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 22),

                    // Buscador
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value.toLowerCase();
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Buscar per títol...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.blue,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Filtros
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<String>(
                          hint: const Text('Seleccionar categoría'),
                          value: selectedCategory,
                          items: ['Salud', 'Investigación'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: resetFilter,
                          child: const Text('Restablir filtres'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Mostrar noticias
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Noticies')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('No hi ha notícies disponibles');
                        }

                        // Filtrado por búsqueda y categoría
                        final filteredNews = snapshot.data!.docs.where((doc) {
                          bool matchesCategory = selectedCategory == null ||
                              doc['Categoria'] == selectedCategory;
                          bool matchesSearch = doc['Titol'] != null &&
                              doc['Titol'].toLowerCase().contains(searchQuery);
                          return matchesCategory && matchesSearch;
                        }).toList();

                        if (filteredNews.isEmpty) {
                          return const Text(
                              'No s\'han trobat notícies amb els filtres aplicats.');
                        }

                        return Column(
                          children: filteredNews.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('Usuarios')
                                  .doc(currentUserId)
                                  .collection('noticiesVistes')
                                  .doc(data['Titol'])
                                  .get(),
                              builder: (context, vistoSnapshot) {
                                if (vistoSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }

                                final isVisto = vistoSnapshot.hasData &&
                                    vistoSnapshot.data!.exists;

                                return InfoCard(
                                  infoUrl: data['url'],
                                  infoTitle: data['Titol'],
                                  infoDescription: data['Descripcio'],
                                  isVisto: isVisto,
                                  onMarkAsVisto: () {
                                    marcarComoVisto(
                                        data['Titol'], currentUserId);
                                  },
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: mostrarImagen ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Visibility(
                visible: mostrarImagen,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Image.asset(
                      'assets/images/+10Puntos.png',
                      width: 250,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> marcarComoVisto(String NoticiaTitle, String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userId)
          .collection('noticiesVistes')
          .doc(NoticiaTitle)
          .get();

      if (!snapshot.exists) {
        await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(userId)
            .collection('noticiesVistes')
            .doc(NoticiaTitle)
            .set({
          'Titol': NoticiaTitle,
          'visto': true,
          'timestampVisto': FieldValue.serverTimestamp(),
        });

        final datosRef = FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(userId)
            .collection('trivial')
            .doc('datos');

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final datosSnapshot = await transaction.get(datosRef);

          if (!datosSnapshot.exists) {
            transaction.set(datosRef, {'coins': 10});
          } else {
            final coinsActuales = datosSnapshot.get('coins') ?? 0;
            transaction.update(datosRef, {'coins': coinsActuales + 10});
          }
        });

        setState(() {
          mostrarImagen = true;
        });
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          mostrarImagen = false;
        });
      }
    } catch (e) {
      print('Error al marcar com a vista o afegir monedes: $e');
    }
  }
}
