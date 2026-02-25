import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class jocPacient extends StatefulWidget {
  final String relatedPatientId;

  const jocPacient({Key? key, required this.relatedPatientId})
      : super(key: key);

  @override
  _jocPacientState createState() => _jocPacientState();
}

class _jocPacientState extends State<jocPacient> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int maxPuntuacion = 0;
  int maxPuntuacionNoHabilitats = 0;
  int points = 0;
  int pointsNoHabilitats = 0;

  bool isLoading = true; // 🔹 Flag de carga

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    try {
      // Solo obtiene un documento: Usuarios/{id}/trivial/datos
      DocumentSnapshot patientData = await _firestore
          .collection('Usuarios')
          .doc(widget.relatedPatientId)
          .collection('trivial')
          .doc('datos')
          .get();

      if (patientData.exists) {
        setState(() {
          maxPuntuacion = patientData['maxPuntuacion'] ?? 0;
          maxPuntuacionNoHabilitats =
              patientData['maxPuntuacionNoHabilitats'] ?? 0;
          points = patientData['points'] ?? 0;
          pointsNoHabilitats = patientData['pointsNoHabilitats'] ?? 0;
          isLoading = false; // 🔹 Datos cargados
        });
      } else {
        setState(() {
          isLoading = false; // 🔹 No hay datos pero ya terminó de cargar
        });
      }
    } catch (error) {
      print('Error al obtener datos del paciente: $error');
      setState(() {
        isLoading = false; // 🔹 Asegurar que el spinner desaparezca
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Informació Joc del Pacient"),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromRGBO(66, 61, 242, 1.0),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildCard('Max. puntuación con habilidades', maxPuntuacion),
                  const SizedBox(height: 10),
                  _buildCard('Max. puntuación sin habilidades',
                      maxPuntuacionNoHabilitats),
                  const SizedBox(height: 10),
                  _buildCard('Última puntuación con habilidades', points),
                  const SizedBox(height: 10),
                  _buildCard(
                      'Última puntuación sin habilidades', pointsNoHabilitats),
                ],
              ),
            ),
    );
  }

  Widget _buildCard(String title, int value) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text('$title: $value',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        contentPadding: const EdgeInsets.all(16.0),
      ),
    );
  }
}
