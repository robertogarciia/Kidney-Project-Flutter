import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kidneyproject/components/video_card.dart';
import 'package:kidneyproject/pages/videosPacient.dart';

class Videos extends StatefulWidget {
  final String userId;

  const Videos({Key? key, required this.userId}) : super(key: key);

  @override
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  String? selectedCategory;
  String searchQuery = '';  // Per emmagatzemar la consulta de cerca

  bool isFamiliar = false;  // Per saber si l'usuari és un familia
  String? relatedPatientId; // Per emmagatzemar l'ID del pacient relacionat
  bool mostrarImagen = false;

  // Funció per verificar el tipus d'usuari
  Future<void> _checkUserType() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .collection('tipusDeUsuario')
        .doc('tipus')
        .get();

    final userData = userDoc.data() as Map<String, dynamic>?;

    if (userData == null) {
      print("Error: No se encontró el documento de tipusDeUsuario para ${widget.userId}");
      return;
    }

    print("Tipo de usuario: ${userData['tipo']}");

    if (userData['tipo'] == 'Familiar') {
      setState(() {
        isFamiliar = true;  // És un familiar, habilitar opcions
      });
      print("Familiar encontrado. Mostrando solo el botón adicional.");

      // Obtenir el pacient relacionat amb aquest familiar
      final relatedPatientDocs = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('relacionFamiliarPaciente')
          .get();

      if (relatedPatientDocs.docs.isEmpty) {
        print("Error: No se encontraron pacientes relacionados para este familiar.");
      } else {
        final relatedPatientData = relatedPatientDocs.docs.first.data();
        final dniPaciente = relatedPatientData['DniPaciente'];  // Obtenim el DNI del pacient
        print("DNI del paciente relacionado: $dniPaciente");

        // Ara, busquem l'ID del pacient a partir del DNI
        await _getPatientIdFromDNI(dniPaciente);
      }
    }
  }

  // Funció per obtenir l'ID del pacient a partir del DNI
  Future<void> _getPatientIdFromDNI(String dniPaciente) async {
    final usersSnapshot = await FirebaseFirestore.instance.collection('Usuarios').get();

    for (var userDoc in usersSnapshot.docs) {
      // Buscar en 'dadesPersonals' per trobar el DNI del pacient
      final personalDataSnapshot = await userDoc.reference
          .collection('dadesPersonals')
          .doc('dades')
          .get();

      if (personalDataSnapshot.exists) {
        final personalData = personalDataSnapshot.data();
        print("Datos personales encontrados en usuario ${userDoc.id}");

        if (personalData?['Dni'] == dniPaciente) {
          // Si es troba el DNI, obtenim l'ID de l'usuari
          setState(() {
            relatedPatientId = userDoc.id;   // Emmagatzemem l'ID del pacient
          });
          print("ID del paciente encontrado: ${userDoc.id}");
          break;
        }
      }
    }
  }

  // Funció per carregar els vídeos
  Future<List<DocumentSnapshot>> _loadVideos() async {
    final videosSnapshot = await FirebaseFirestore.instance
        .collection('Videos')
        .get();

    if (videosSnapshot.docs.isNotEmpty) {
      return videosSnapshot.docs;// Retorna tots els vídeos
    }

    print("Error: No se encontraron videos.");
    return [];
  }

  @override
  void initState() {
    super.initState();
    _checkUserType();  // Verificar el tipus d'usuari quan es carrega la pantalla
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color(0xFFFF603D),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Tornar enrere
          },
        ),actions: [
        if (isFamiliar)
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: ElevatedButton(
              onPressed: () {
                if (relatedPatientId != null) {
                  // Imprimir el ID del paciente en la consola
                  print('Ver videos de mi paciente con ID: $relatedPatientId');

                  // Navegar a la página de videosPacient
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => videosPacient(relatedPatientId: relatedPatientId!),
                    ),
                  );
                } else {
                  // Imprimir un missatge si no se ha trobat el ID del pacient
                  print('Aún no se ha encontrado el ID del paciente.');
                }
              },
              child: Text('Veure vídeos del meu pacient'),
            ),
          ),
      ],


      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20),
                    Text(
                      'Vídeos',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
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
                            prefixIcon: Icon(Icons.search, color: Colors.blue),
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<String>(
                          hint: Text('Seleccionar categoría'),
                          value: selectedCategory,
                          items: ['Diàlisis', 'Nutrició'].map((String value) {
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
                          onPressed: () {
                            setState(() {
                              selectedCategory = null;
                              searchQuery = '';
                            });
                          },
                          child: Text('Restablir filtre'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    FutureBuilder<List<DocumentSnapshot>>(
                      future: _loadVideos(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text('No hi ha vídeos disponibles');
                        }

                        List<DocumentSnapshot> filteredVideos = snapshot.data!.where((doc) {
                          bool matchesCategory = selectedCategory == null ||
                              doc['Categoria'] == selectedCategory;
                          bool matchesSearch = doc['Titol'] != null &&
                              doc['Titol'].toLowerCase().contains(searchQuery);
                          return matchesCategory && matchesSearch;
                        }).toList();

                        if (filteredVideos.isEmpty) {
                          return Text(
                              'No se encontraron videos con los filtros aplicados.');
                        }

                        return Column(
                          children: filteredVideos.map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;

                            return VideoCard(
                              videoUrl: data['url'],
                              videoTitle: data['Titol'],
                              videoCategoria: data['Categoria'],
                              userId: widget.userId,
                              onMarkAsViewed: marcarComoVisto,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          AnimatedOpacity(
            opacity: mostrarImagen ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: Visibility(
              visible: mostrarImagen,
              child: Container(
                color: Colors.black.withOpacity(0.5), // Fondo oscuro opcional
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


    );
  }

  Future<void> marcarComoVisto(String videoTitle) async {
    try {
      print('Widget ID: ${widget.userId}');

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('videosVistos')
          .doc(videoTitle)
          .get();

      if (!snapshot.exists) {
        // Guardar com a vist
        await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(widget.userId)
            .collection('videosVistos')
            .doc(videoTitle)
            .set({
          'Titol': videoTitle,
          'visto': true,
          'timestampVisto': FieldValue.serverTimestamp(),
        });

        // Sumar coins
        DocumentReference datosRef = FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(widget.userId)
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

        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            mostrarImagen = false;
          });
        });
      } else {
        print('El video "$videoTitle" ya está marcado como visto.');
      }
    } catch (e) {
      print('Error al guardar el estado del video o añadir coins: $e');
    }
  }

}
