import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/components/info_card.dart';
import 'noticiesPacient.dart';

class noticiesPage extends StatefulWidget {
  final String userId;

  const noticiesPage({Key? key, required this.userId}) : super(key: key);

  @override
  _noticiesPageState createState() => _noticiesPageState();
}

class _noticiesPageState extends State<noticiesPage> {
  String? selectedCategory;
  String searchQuery = '';
  bool mostrarImagen = false;

  bool isFamiliar = false;
  String? relatedPatientId;
  bool loadingRelacion = false;

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .collection('tipusDeUsuario')
        .doc('tipus')
        .get();

    final userData = userDoc.data() as Map<String, dynamic>?;

    if (userData == null) return;

    if (userData['tipo'] == 'Familiar') {
      setState(() {
        isFamiliar = true;
        loadingRelacion = true;
      });

      final relatedPatientDocs = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('relacionFamiliarPaciente')
          .get();

      if (relatedPatientDocs.docs.isNotEmpty) {
        final dniPaciente = relatedPatientDocs.docs.first.data()['DniPaciente'];
        await _getPatientIdFromDNI(dniPaciente);
      }

      setState(() {
        loadingRelacion = false;
      });
    }
  }

  Future<void> _getPatientIdFromDNI(String dniPaciente) async {
    final usersSnapshot =
    await FirebaseFirestore.instance.collection('Usuarios').get();

    for (var userDoc in usersSnapshot.docs) {
      final personalDataSnapshot = await userDoc.reference
          .collection('dadesPersonals')
          .doc('dades')
          .get();

      if (personalDataSnapshot.exists) {
        final personalData = personalDataSnapshot.data();
        if (personalData?['Dni'] == dniPaciente) {
          setState(() {
            relatedPatientId = userDoc.id;
          });
          break;
        }
      }
    }
  }

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
        backgroundColor: Color(0xFFFFD53D),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (isFamiliar)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: loadingRelacion
                  ? Center(child: CircularProgressIndicator(color: Colors.white))
                  : relatedPatientId != null
                  ? ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => noticiesPacient(
                          relatedPatientId: relatedPatientId!),
                    ),
                  );
                },
                child: Text('Veure notícies del meu pacient'),
              )
                  : SizedBox.shrink(),
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
                    SizedBox(height: 20),
                    Text(
                      'Noticies',
                      style:
                      TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 22),

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
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value.toLowerCase();
                            });
                          },
                          decoration: InputDecoration(
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
                    SizedBox(height: 20),

                    // Filtros
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<String>(
                          hint: Text('Seleccionar categoría'),
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
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: resetFilter,
                          child: Text('Restablir filtres'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Mostrar noticias
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Noticies')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text('No hi ha notícies disponibles');
                        }

                        List<DocumentSnapshot> filteredNews =
                        snapshot.data!.docs.where((doc) {
                          bool matchesCategory = selectedCategory == null ||
                              doc['Categoria'] == selectedCategory;
                          bool matchesSearch = doc['Titol'] != null &&
                              doc['Titol']
                                  .toLowerCase()
                                  .contains(searchQuery);
                          return matchesCategory && matchesSearch;
                        }).toList();

                        if (filteredNews.isEmpty) {
                          return Text(
                              'No s\'han trobat notícies amb els filtres aplicats.');
                        }

                        return Column(
                          children: filteredNews.map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;

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
                                  return CircularProgressIndicator();
                                }
                                bool isVisto = vistoSnapshot.hasData &&
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
              duration: Duration(milliseconds: 300),
              child: Visibility(
                visible: mostrarImagen,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Image.asset(
                      'lib/images/+10Puntos.png',
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
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
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

        DocumentReference datosRef = FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(userId)
            .collection('trivial')
            .doc('datos');

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot datosSnapshot = await transaction.get(datosRef);

          if (!datosSnapshot.exists) {
            transaction.set(datosRef, {'coins': 10});
          } else {
            int coinsActuales = datosSnapshot.get('coins') ?? 0;
            transaction.update(datosRef, {'coins': coinsActuales + 10});
          }
        });

        setState(() {
          mostrarImagen = true;
        });
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          mostrarImagen = false;
        });
      }
    } catch (e) {
      print('Error al marcar com a vista o afegir monedes: $e');
    }
  }
}
