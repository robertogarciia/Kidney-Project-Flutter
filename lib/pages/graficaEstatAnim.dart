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
  final List<int> years = List<int>.generate(10, (index) => 2023 + index);
  int selectedYear = DateTime.now().year;
  bool isLoading = true;
  bool isFamiliar = false;
  String relatedPatientId = '';

  final List<String> months = [
    'Gener', 'Febrer', 'Març', 'Abril', 'Maig', 'Juny',
    'Juliol', 'Agost', 'Setembre', 'Octubre', 'Novembre', 'Desembre',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = months[now.month - 1];
    moodData = {'Content/a': 0, 'Neutral': 0, 'Trist/a': 0};
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .collection('tipusDeUsuario')
        .doc('tipus')
        .get();

    final userData = userDoc.data();
    if (userData == null) {
      print("Error: No se encontró el tipo de usuario.");
      return;
    }

    if (userData['tipo'] == 'Familiar') {
      setState(() {
        isFamiliar = true;
      });

      final relatedDocs = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('relacionFamiliarPaciente')
          .get();

      if (relatedDocs.docs.isEmpty) {
        print("Error: No hay relación con paciente.");
        return;
      }

      final dniPaciente = relatedDocs.docs.first.data()['DniPaciente'];
      await _getPatientIdFromDNI(dniPaciente);
    } else {
      fetchMoodData(selectedMonth);
    }
  }

  Future<void> _getPatientIdFromDNI(String dniPaciente) async {
    final snapshot = await FirebaseFirestore.instance.collection('Usuarios').get();

    for (var userDoc in snapshot.docs) {
      final personalDataSnapshot = await userDoc.reference
          .collection('dadesPersonals')
          .doc('dades')
          .get();

      if (personalDataSnapshot.exists) {
        final data = personalDataSnapshot.data();
        if (data?['Dni'] == dniPaciente) {
          setState(() {
            relatedPatientId = userDoc.id;
          });
          break;
        }
      }
    }

    fetchMoodData(selectedMonth);
  }

  Future<void> fetchMoodData(String month) async {
    setState(() => isLoading = true);

    try {
      final start = DateTime(selectedYear, months.indexOf(month) + 1, 1);
      final end = DateTime(selectedYear, months.indexOf(month) + 2, 0, 23, 59, 59);

      final snapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(isFamiliar ? relatedPatientId : widget.userId)
          .collection('estatAnim')
          .where('Data', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('Data', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      final counts = {'Content/a': 0, 'Neutral': 0, 'Trist/a': 0};

      for (var doc in snapshot.docs) {
        final mood = doc['Estat'];
        if (counts.containsKey(mood)) {
          counts[mood] = counts[mood]! + 1;
        }
      }

      setState(() {
        moodData = counts;
        isLoading = false;
      });
    } catch (e) {
      print('Error al obtener datos: $e');
      setState(() => isLoading = false);
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
              MaterialPageRoute(builder: (context) => MenuPrincipal(userId: widget.userId)),
            );
          },
        ),
        title: const Text(
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
            children: [
              Text(
                'Estat de $selectedMonth $selectedYear',
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Selector de mes
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.pinkAccent, width: 2),
                  color: Colors.pinkAccent.withOpacity(0.1),
                ),
                child: DropdownButton<String>(
                  value: selectedMonth,
                  items: months.map((month) {
                    return DropdownMenuItem(
                      value: month,
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, color: Colors.black),
                          const SizedBox(width: 10),
                          Text(month, style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
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

              const SizedBox(height: 20),

              // Selector de año
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.pinkAccent, width: 2),
                  color: Colors.pinkAccent.withOpacity(0.1),
                ),
                child: DropdownButton<int>(
                  value: selectedYear,
                  items: years.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.black),
                          const SizedBox(width: 10),
                          Text('$year', style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedYear = newValue!;
                      fetchMoodData(selectedMonth);
                    });
                  },
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  iconEnabledColor: Colors.black,
                ),
              ),

              const SizedBox(height: 30),

              isLoading
                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.pinkAccent))
                  : (moodData.values.every((count) => count == 0))
                  ? const Text(
                'No hi ha dades registrades',
                style: TextStyle(fontSize: 18, color: Colors.pinkAccent, fontWeight: FontWeight.bold),
              )
                  : Container(
                height: 300,
                width: 300,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: moodData['Content/a']!.toDouble(),
                        color: Colors.green,
                        title: 'Content/a: ${moodData['Content/a']}',
                        titleStyle: const TextStyle(color: Colors.white, fontSize: 15),
                        radius: 80,
                      ),
                      PieChartSectionData(
                        value: moodData['Neutral']!.toDouble(),
                        color: Colors.orange,
                        title: 'Neutral: ${moodData['Neutral']}',
                        titleStyle: const TextStyle(color: Colors.white, fontSize: 15),
                        radius: 80,
                      ),
                      PieChartSectionData(
                        value: moodData['Trist/a']!.toDouble(),
                        color: Colors.red,
                        title: 'Trist/a: ${moodData['Trist/a']}',
                        titleStyle: const TextStyle(color: Colors.white, fontSize: 15),
                        radius: 80,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text('Llegenda', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('lib/images/caraFeliz.png', 'Content/a'),
                  const SizedBox(width: 30),
                  _buildLegendItem('lib/images/caraNormal.png', 'Neutral'),
                  const SizedBox(width: 30),
                  _buildLegendItem('lib/images/caraTriste.png', 'Trist/a'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String imagePath, String label) {
    return Column(
      children: [
        Image.asset(imagePath, height: 50, width: 50),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
