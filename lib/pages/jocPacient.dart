import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Necesario para formatear la fecha

class jocPacient extends StatefulWidget {
  final String relatedPatientId;

  const jocPacient({Key? key, required this.relatedPatientId}) : super(key: key);

  @override
  _jocPacientState createState() => _jocPacientState();
}

class _jocPacientState extends State<jocPacient> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int maxPuntuacion = 0;
  int maxPuntuacionNoHabilitats = 0;
  int points = 0;
  int pointsNoHabilitats = 0;

  @override
  void initState() {
    super.initState();
    _fetchPatientData();  // Llamada per obtenir les dades de puntuacions
  }

  Future<void> _fetchPatientData() async {
    try {
      // Cargar les dades de la subcolección 'trivial' del pacient relacionat
      DocumentSnapshot patientData = await _firestore
          .collection('Usuarios')
          .doc(widget.relatedPatientId)
          .collection('trivial')
          .doc('datos')
          .get();

      // Verificar si les dades existeixen
      if (patientData.exists) {
        setState(() {
          maxPuntuacion = patientData['maxPuntuacion'] ?? 0;
          maxPuntuacionNoHabilitats = patientData['maxPuntuacionNoHabilitats'] ?? 0;
          points = patientData['points'] ?? 0;
          pointsNoHabilitats = patientData['pointsNoHabilitats'] ?? 0;
        });
      }
    } catch (error) {
      print('Error al obtener datos del paciente: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Informació Joc del Pacient"),
        foregroundColor: Colors.white,

        backgroundColor: const Color.fromRGBO(66, 61, 242, 1.0),
      ),
      body: (maxPuntuacion == 0 && maxPuntuacionNoHabilitats == 0 && points == 0 && pointsNoHabilitats == 0)
          ? Center(child: CircularProgressIndicator()) // Cargando datos
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text('Max. puntuación con habilidades: $maxPuntuacion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                contentPadding: EdgeInsets.all(16.0),
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text('Max. puntuación sin habilidades: $maxPuntuacionNoHabilitats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                contentPadding: EdgeInsets.all(16.0),
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text('Última puntuación con habilidades: $points', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                contentPadding: EdgeInsets.all(16.0),
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text('Última puntuación sin habilidades: $pointsNoHabilitats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                contentPadding: EdgeInsets.all(16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
