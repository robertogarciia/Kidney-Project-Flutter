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
  String selectedMonth = ''; // Inicialmente vacío
  bool isLoading = true; // Indicador de carga

  // Lista de meses en catalán
  final List<String> months = [
    'Gener',
    'Febrer',
    'Març',
    'Abril',
    'Maig',
    'Juny',
    'Juliol',
    'Agost',
    'Setembre',
    'Octubre',
    'Novembre',
    'Desembre',
  ];
  @override
  void initState() {
    super.initState();

    // Obtener el mes actual
    final DateTime now = DateTime.now();
    selectedMonth = months[now.month - 1]; // Ajustar el mes para que coincida con el índice de la lista

    moodData = {'Content/a': 0, 'Neutral': 0, 'Trist/a': 0};
    fetchMoodData(selectedMonth); // Cargar datos al iniciar
  }

  // Función para obtener los datos de Firestore filtrados por mes
  Future<void> fetchMoodData(String selectedMonth) async {
    setState(() {
      isLoading = true; // Indicamos que estamos cargando
    });

    try {
      // Define las fechas de inicio y fin del mes seleccionado
      DateTime startOfMonth = DateTime(2025, months.indexOf(selectedMonth) + 1, 1);
      DateTime endOfMonth = DateTime(2025, months.indexOf(selectedMonth) + 1 + 1, 0, 23, 59, 59);

      Timestamp startTimestamp = Timestamp.fromDate(startOfMonth);
      Timestamp endTimestamp = Timestamp.fromDate(endOfMonth);

      // Obtener los datos de Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('estatAnim')
          .where('Data', isGreaterThanOrEqualTo: startTimestamp)
          .where('Data', isLessThanOrEqualTo: endTimestamp)
          .get();

      // Procesar los datos obtenidos
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
        moodData = moodCounts; // Actualiza los datos de la gráfica
        isLoading = false; // Termina la carga
      });
    } catch (e) {
      print('Error al obtener datos: $e');
      setState(() {
        isLoading = false; // En caso de error también se detiene la carga
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
            // Navegar al menú principal usando Navigator
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MenuPrincipal(userId: widget.userId),
              ),
            );
          },
        ),
        title: Text(
          'Estat d\'ànim',
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
              // Título dinámico con el mes actual

              Text(
                'Estat del mes de $selectedMonth',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 30),

              // Dropdown para seleccionar el mes con ícono de calendario
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.pinkAccent, width: 2),
                  color: Colors.pinkAccent.withOpacity(0.1), // Fondo suave
                ),
                child: DropdownButton<String>(
                  value: selectedMonth,
                  items: months.map((month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.black), // Ícono de calendario
                          SizedBox(width: 10), // Espaciado
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
                      fetchMoodData(selectedMonth); // Recargar los datos con el mes seleccionado
                    });
                  },
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  iconEnabledColor: Colors.black, // Color del icono
                ),
              ),

              SizedBox(height: 30),

              // Mostrar el gráfico o un indicador de carga
              isLoading
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.pinkAccent),
              ) // Muestra un loading mientras se obtienen los datos
                  : (moodData['Content/a'] == 0 && moodData['Neutral'] == 0 && moodData['Trist/a'] == 0)
                  ? Text(
                'No hi ha dades registrades',
                style: TextStyle(fontSize: 18, color: Colors.pinkAccent, fontWeight: FontWeight.bold),
              ) // Muestra un mensaje si no hay datos registrados
                  : Container(
                height: 300, // Tamaño del gráfico
                width: 300,  // Tamaño del gráfico
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
                        radius: 80, // Tamaño del radio
                      ),
                      PieChartSectionData(
                        value: moodData['Neutral']?.toDouble() ?? 0.0,
                        color: Colors.orange,
                        title: 'Neutral: ${moodData['Neutral'] ?? 0}',
                        titleStyle: TextStyle(color: Colors.white, fontSize: 15),
                        radius: 80, // Tamaño del radio
                      ),
                      PieChartSectionData(
                        value: moodData['Trist/a']?.toDouble() ?? 0.0,
                        color: Colors.red,
                        title: 'Trist/a: ${moodData['Trist/a'] ?? 0}',
                        titleStyle: TextStyle(color: Colors.white, fontSize: 15),
                        radius: 80, // Tamaño del radio
                      ),
                    ],
                  ),
                ),
              ),
//hola
              SizedBox(height: 30),

              // Sección con los íconos de las caras
              //titulo leyenda centrado a la izquierda
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
                        'lib/images/caraFeliz.png', // Asegúrate de que la ruta sea correcta
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
                        'lib/images/caraNormal.png', // Asegúrate de que la ruta sea correcta
                        height: 50,
                        width: 50,
                      ),
                      Text('Neutral', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  SizedBox(width: 30),
                  Column(
                    children: [
                      Image.asset(
                        'lib/images/caraTriste.png', // Asegúrate de que la ruta sea correcta
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
