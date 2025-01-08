import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/components/textfield.dart';
import 'package:kidneyproject/pages/menu_principal.dart';

void main() {
  runApp(const Formulario3(userId: 'userID_value')); // Aquí proporciona el valor real de userID
}

class Formulario3 extends StatelessWidget {
  final String userId;

  const Formulario3({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dades Mediques',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Formulario(userId: userId), // Pasa el userId al widget Formulario
    );
  }
}

class Formulario extends StatefulWidget {
  final String userId;

  const Formulario({Key? key, required this.userId}) : super(key: key);

  @override
  _FormularioState createState() => _FormularioState();
}

class _FormularioState extends State<Formulario> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _alcadaController = TextEditingController();
  TextEditingController _pesController = TextEditingController();
  String? _selectedEstadio;
  TextEditingController _estatController = TextEditingController();
  String? _selectedDiabetic;
  String? _selectedHipertens;
  String? _selectedPacientExpert;
  String? _selectedActivitatFisica;

  Future<void> guardarDatosMedicos(String userId, String diabetic, String hipertens, String pacientExpert, String activitatFisica, String estadio, String alcada, String pes, String estat) async {
    try {
      // Guardar los datos médicos dentro del documento 'dadesMediques'
      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userId)
          .collection('dadesMediques')
          .doc('datos')
          .set({
        'alcada': alcada,
        'pes': pes,
        'estadio': estadio,
        'estat': estat,
        'diabetic': diabetic,
        'hipertens': hipertens,
        'pacientExpert': pacientExpert,
        'activitatFisica': activitatFisica,
      });

      // Redirigir al menú principal después de guardar los datos
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MenuPrincipal(userId: userId)),
      );
    } catch (error) {
      // Manejo de errores
      print('Error al guardar los datos médicos: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dades Mèdiques'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xA6403DF3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _alcadaController,
                        decoration: InputDecoration(
                          hintText: 'Alçada',
                          suffixText: 'cm',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: _pesController,
                        decoration: InputDecoration(
                          hintText: 'Pes',
                          suffixText: 'Kg',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      const Text(
                        "Estadio",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 60,
                        width: 300,
                        child: DropdownButtonFormField(
                          items: List.generate(25, (index) => (index + 1).toString()).map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          value: _selectedEstadio,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedEstadio = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Selecciona una opció',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                       TextFormField(
                        controller: _estatController,
                        decoration: InputDecoration(
                          hintText: 'Estat',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      const Text(
                        "Diabètic",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 60,
                        width: 300,
                        child: DropdownButtonFormField(
                          items: ['Sí', 'No'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          value: _selectedDiabetic,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedDiabetic = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Selecciona una opció',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      const Text(
                        "Hipertens",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 60,
                        width: 300,
                        child: DropdownButtonFormField(
                          items: ['Sí', 'No'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          value: _selectedHipertens,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedHipertens = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Selecciona una opció',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      const Text(
                        "Pacient Expert",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 60,
                        width: 300,
                        child: DropdownButtonFormField(
                          items: ['Sí', 'No'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          value: _selectedPacientExpert,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedPacientExpert = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Selecciona una opció',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      const Text(
                        "Activitat Física",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 60,
                        width: 300,
                        child: DropdownButtonFormField(
                          items: ['Sí', 'No'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          value: _selectedActivitatFisica,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedActivitatFisica = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Selecciona una opció',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
               Padding(
  padding: const EdgeInsets.symmetric(vertical: 16.0),
  child: Column(
    children: [
      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Si el formulario es válido, guardar los datos médicos
                  guardarDatosMedicos(
                    widget.userId,
                    _selectedDiabetic ?? '',
                    _selectedHipertens ?? '',
                    _selectedPacientExpert ?? '',
                    _selectedActivitatFisica ?? '',
                    _selectedEstadio ?? '',
                    '${_alcadaController.text} cm',
                    '${_pesController.text} kg',
                    _estatController.text
                  );

                  // Mostrar un diálogo de éxito
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text('Les dades mèdiques s\'han guardat correctament.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cerrar'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Enviar'),
            ),
          ),
        ],
      ),
    ],
  ),
),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
