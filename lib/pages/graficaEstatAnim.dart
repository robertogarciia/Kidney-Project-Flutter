import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import 'menu_principal.dart';

class graficaEstatAnim extends StatefulWidget {
  final String userId;

  const graficaEstatAnim({Key? key, required this.userId}) : super(key: key);

  @override
  _graficaEstatAnimState createState() => _graficaEstatAnimState();
}
class _graficaEstatAnimState extends State<graficaEstatAnim> {
  late Map<String, int> moodData;
  String selectedMonth = '';
  bool isLoading = true;
  bool isFamiliar = false; // Indicador de si el usuario es un familiar
  String relatedPatientId = ''; // ID del paciente relacionado

  final List<String> months = [
    'Gener', 'Febrer', 'Març', 'Abril', 'Maig', 'Juny', 'Juliol', 'Agost',
    'Setembre', 'Octubre', 'Novembre', 'Desembre',
  ];

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    selectedMonth = months[now.month - 1];
    moodData = {'Content/a': 0, 'Neutral': 0, 'Trist/a': 0};
    _checkUserType();  // Verificar el tipo de usuario al iniciar
  }

  // Verificar el tipo de usuario
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

    if (userData['tipo'] == 'Familiar') {
      setState(() {
        isFamiliar = true;
      });

      // Obtener el paciente relacionado con este familiar
      final relatedPatientDocs = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('relacionFamiliarPaciente')
          .get();

      if (relatedPatientDocs.docs.isEmpty) {
        print("Error: No se encontraron pacientes relacionados para este familiar.");
      } else {
        final relatedPatientData = relatedPatientDocs.docs.first.data();
        final dniPaciente = relatedPatientData['DniPaciente'];
        await _getPatientIdFromDNI(dniPaciente);
      }
    } else {
      // Si es un paciente, podemos continuar sin hacer nada adicional
      fetchMoodData(selectedMonth);
    }
  }

  // Obtener el ID del paciente a partir del DNI
  Future<void> _getPatientIdFromDNI(String dniPaciente) async {
    final usersSnapshot = await FirebaseFirestore.instance.collection('Usuarios').get();

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

    // Una vez que tengamos el ID del paciente, podemos cargar los datos
    fetchMoodData(selectedMonth);
  }

  // Función para obtener los datos del estado de ánimo del paciente o del usuario
  Future<void> fetchMoodData(String selectedMonth) async {
    setState(() {
      isLoading = true;
    });

    try {
      DateTime startOfMonth = DateTime(2025, months.indexOf(selectedMonth) + 1, 1);
      DateTime endOfMonth = DateTime(2025, months.indexOf(selectedMonth) + 1 + 1, 0, 23, 59, 59);

      Timestamp startTimestamp = Timestamp.fromDate(startOfMonth);
      Timestamp endTimestamp = Timestamp.fromDate(endOfMonth);

      final snapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(isFamiliar ? relatedPatientId : widget.userId)  // Usar el ID del paciente si es familiar
          .collection('estatAnim')
          .where('Data', isGreaterThanOrEqualTo: startTimestamp)
          .where('Data', isLessThanOrEqualTo: endTimestamp)
          .get();

      final moodCounts = {'Content/a': 0, 'Neutral': 0, 'Trist/a': 0};

      for (var doc in snapshot.docs) {
        if (doc.data().containsKey('Estat')) {
          String mood = doc['Estat'];
          if (moodCounts.containsKey(mood)) {
            moodCounts[mood] = moodCounts[mood]! + 1;
          }
        }
      }

      setState(() {
        moodData = moodCounts;
        isLoading = false;
      });
    } catch (e) {
      print('Error al obtener datos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MenuPrincipal(userId: widget.userId),
              ),
            );
          },
        ),
        title: Text(
          'Estat d\'ànim del Pacient',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Estat del mes de $selectedMonth',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              // Dropdown per a seleccionar el mes amb ícono del calendari
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.pinkAccent, width: 2),
                  color: Colors.pinkAccent.withOpacity(0.1),
                ),
                child: DropdownButton<String>(
                  value: selectedMonth,
                  items: months.map((month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.black),
                          SizedBox(width: 10),
                          Text(
                            month,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMonth = newValue!;
                      fetchMoodData(selectedMonth);
                    });
                  },
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  iconEnabledColor: Colors.black,
                ),
              ),
              SizedBox(height: 30),
              // Mostrar el gráfico o un indicador de carga
              isLoading
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.pinkAccent),
              )
                  : (moodData['Content/a'] == 0 && moodData['Neutral'] == 0 && moodData['Trist/a'] == 0)
                  ? Text(
                'No hi ha dades registrades',
                style: TextStyle(fontSize: 18, color: Colors.pinkAccent, fontWeight: FontWeight.bold),
              )
                  : Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: moodData['Content/a']?.toDouble() ?? 0.0,
                        color: Colors.green,
                        title: 'Content/a: ${moodData['Content/a'] ?? 0}',
                        titleStyle: TextStyle(color: Colors.white, fontSize: 15),
                        radius: 80,
                      ),
                      PieChartSectionData(
                        value: moodData['Neutral']?.toDouble() ?? 0.0,
                        color: Colors.orange,
                        title: 'Neutral: ${moodData['Neutral'] ?? 0}',
                        titleStyle: TextStyle(color: Colors.white, fontSize: 15),
                        radius: 80,
                      ),
                      PieChartSectionData(
                        value: moodData['Trist/a']?.toDouble() ?? 0.0,
                        color: Colors.red,
                        title: 'Trist/a: ${moodData['Trist/a'] ?? 0}',
                        titleStyle: TextStyle(color: Colors.white, fontSize: 15),
                        radius: 80,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Llegenda',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: [
                      Image.asset(
                        'lib/images/caraFeliz.png',
                        height: 50,
                        width: 50,
                      ),
                      Text('Content/a', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  SizedBox(width: 30),
                  Column(
                    children: [
                      Image.asset(
                        'lib/images/caraNormal.png',
                        width: 50,
                      ),
                      Text('Neutral', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  SizedBox(width: 30),
                  Column(
                    children: [
                      Image.asset(
                        'lib/images/caraTriste.png',
                        height: 50,
                        width: 50,
                      ),
                      Text('Trist/a', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
