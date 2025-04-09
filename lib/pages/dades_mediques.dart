import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/components/textfield.dart';
import 'package:kidneyproject/pages/estatAnim.dart';
import 'package:kidneyproject/pages/menu_principal.dart';

void main() {
  runApp(const Formulario3(
      userId: 'userID_value')); // Aquí proporciona el valor real de userID
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
      home: Formulario(userId: userId), // Pasa el userId al widget al Formulari
    );
  }
}

class Formulario extends StatefulWidget {
  final String userId;

  const Formulario({Key? key, required this.userId}) : super(key: key);

  @override
  _FormularioState createState() => _FormularioState();
}
// Formulari per a recopilar dades mediques del usuari
class _FormularioState extends State<Formulario> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _alcadaController = TextEditingController();
  TextEditingController _pesController = TextEditingController();
  String? _selectedEstadio;
  String? _estatController;
  String? _selectedDiabetic;
  String? _selectedHipertens;
  String? _selectedPacientExpert;
  String? _selectedActivitatFisica;
  String? _selectedTipusC;

  Future<void> guardarDatosMedicos(
      String userId,
      String diabetic,
      String hipertens,
      String pacientExpert,
      String activitatFisica,
      String estadio,
      String alcada,
      String pes,
      String estat,
      String tipusC) async {
    try {
      // Guardar les dades mediques dins del document 'dadesMediques'
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
        'tipusC': _selectedTipusC,
      });

      // Redirigir al menú principal después de guardar les dades
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EstatAnim(userId: userId)),
      );
    } catch (error) {
      // Manejo de errores
      print('Error al guardar los datos médicos: $error');
    }
  }
// Funció per a determinar el tipo de dieta en funció de los dades mèdiques
  void determinarTipusC() {
    double alcadaEnMetros =
        double.tryParse(_alcadaController.text.replaceAll(',', '.')) ?? 0;
    double pes = double.tryParse(_pesController.text.replaceAll(',', '.')) ?? 0;

    double imc =
        alcadaEnMetros > 0 ? (pes / (alcadaEnMetros * alcadaEnMetros)) : 0;

    String categoriaIMC;
    if (imc < 18.5) {
      categoriaIMC = 'Desnodrit';
    } else if (imc >= 25) {
      categoriaIMC = 'Obès';
    } else {
      categoriaIMC = 'Normal';
    }

    print('IMC: $imc, Categoría: $categoriaIMC');

    if (categoriaIMC == 'Normal' &&
        _selectedActivitatFisica == 'Sí' &&
        _estatController == 'Pre-Diàlisi' &&
        _selectedDiabetic == 'No') {
      _selectedTipusC = 'C1';
    } else if (categoriaIMC == 'Normal' &&
        _selectedActivitatFisica == 'Sí' &&
        _estatController == 'Pre-Diàlisi' &&
        _selectedDiabetic == 'Sí') {
      _selectedTipusC = 'C2';
    } else if (categoriaIMC == 'Normal' &&
        _selectedActivitatFisica == 'Sí' &&
        _estatController == 'Diàlisi' &&
        _selectedDiabetic == 'No') {
      _selectedTipusC = 'C3';
    } else if (categoriaIMC == 'Normal' &&
        _selectedActivitatFisica == 'Sí' &&
        _estatController == 'Diàlisi' &&
        _selectedDiabetic == 'Sí') {
      _selectedTipusC = 'C4';
    } else if (categoriaIMC == 'Normal' &&
        _selectedActivitatFisica == 'No' &&
        _estatController == 'Pre-Diàlasi' &&
        _selectedDiabetic == 'No') {
      _selectedTipusC = 'C5';
    } else if (categoriaIMC == 'Normal' &&
        _selectedActivitatFisica == 'No' &&
        _estatController == 'Pre-Diàlisi' &&
        _selectedDiabetic == 'Sí') {
      _selectedTipusC = 'C6';
    } else if (categoriaIMC == 'Normal' &&
        _selectedActivitatFisica == 'No' &&
        _estatController == 'Diàlisi' &&
        _selectedDiabetic == 'No') {
      _selectedTipusC = 'C7';
    } else if (categoriaIMC == 'Normal' &&
        _selectedActivitatFisica == 'No' &&
        _estatController == 'Diàlisi' &&
        _selectedDiabetic == 'Sí') {
      _selectedTipusC = 'C8';
    } else if (categoriaIMC == 'Desnodrit' &&
        _selectedActivitatFisica == 'Sí' &&
        _estatController == 'Pre-Diàlisi' &&
        _selectedDiabetic == 'No') {
      _selectedTipusC = 'C9';
    } else if (categoriaIMC == 'Desnodrit' &&
        _selectedActivitatFisica == 'Sí' &&
        _estatController == 'Pre-Diàlisi' &&
        _selectedDiabetic == 'Sí') {
      _selectedTipusC = 'C10';
    } else if (categoriaIMC == 'Desnodrit' &&
        _selectedActivitatFisica == 'Sí' &&
        _estatController == 'Diàlisi' &&
        _selectedDiabetic == 'No') {
      _selectedTipusC = 'C11';
    } else if (categoriaIMC == 'Desnodrit' &&
        _selectedActivitatFisica == 'Sí' &&
        _estatController == 'Diàlisi' &&
        _selectedDiabetic == 'Sí') {
      _selectedTipusC = 'C12';
    } else if (categoriaIMC == 'Desnodrit' &&
        _selectedActivitatFisica == 'No' &&
        _estatController == 'Pre-Diàlisi' &&
        _selectedDiabetic == 'No') {
      _selectedTipusC = 'C13';
    } else if (categoriaIMC == 'Desnodrit' &&
        _selectedActivitatFisica == 'No' &&
        _estatController == 'Pre-Diàlisi' &&
        _selectedDiabetic == 'Sí') {
      _selectedTipusC = 'C14';
    } else if (categoriaIMC == 'Desnodrit' &&
        _selectedActivitatFisica == 'No' &&
        _estatController == 'Diàlisi' &&
        _selectedDiabetic == 'No') {
      _selectedTipusC = 'C15';
    } else if (categoriaIMC == 'Desnodrit' &&
        _selectedActivitatFisica == 'No' &&
        _estatController == 'Diàlisi' &&
        _selectedDiabetic == 'Sí') {
      _selectedTipusC = 'C16';
    } else if (categoriaIMC == 'Obès' &&
        _selectedActivitatFisica == 'Sí' &&
        _estatController == 'Pre-Diàlisi' &&
        _selectedDiabetic == 'No') {
      _selectedTipusC = 'C17';
    } else if (categoriaIMC == 'Obès' &&
        _selectedActivitatFisica == 'Sí' &&
        _estatController == 'Pre-Diàlisi' &&
        _selectedDiabetic == 'Sí') {
      _selectedTipusC = 'C18';
    } else if (categoriaIMC == 'Obès' &&
        _selectedActivitatFisica == 'Sí' &&
        _estatController == 'Diàlisi' &&
        _selectedDiabetic == 'No') {
      _selectedTipusC = 'C19';
    } else if (categoriaIMC == 'Obès' &&
        _selectedActivitatFisica == 'Sí' &&
        _estatController == 'Diàlisi' &&
        _selectedDiabetic == 'Sí') {
      _selectedTipusC = 'C20';
    } else if (categoriaIMC == 'Obès' &&
        _selectedActivitatFisica == 'No' &&
        _estatController == 'Pre-Diàlisi' &&
        _selectedDiabetic == 'No') {
      _selectedTipusC = 'C21';
    } else if (categoriaIMC == 'Obès' &&
        _selectedActivitatFisica == 'No' &&
        _estatController == 'Pre-Diàlisi' &&
        _selectedDiabetic == 'Sí') {
      _selectedTipusC = 'C22';
    } else if (categoriaIMC == 'Obès' &&
        _selectedActivitatFisica == 'No' &&
        _estatController == 'Diàlisi' &&
        _selectedDiabetic == 'No') {
      _selectedTipusC = 'C23';
    } else if (categoriaIMC == 'Obès' &&
        _selectedActivitatFisica == 'No' &&
        _estatController == 'Diàlisi' &&
        _selectedDiabetic == 'Sí') {
      _selectedTipusC = 'C24';
    } else {
      _selectedTipusC = 'No Determinat';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 161, 196, 249),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                const Text(
                  "Dades Mèdiques",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _alcadaController,
                        decoration: InputDecoration(
                          hintText: 'Alçada',
                          suffixText: 'm',
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
                          items: List.generate(
                                  5, (index) => (index + 1).toString())
                              .map((String value) {
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
                      SizedBox(height: 10),
                      const Text(
                        "Estat",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 60,
                        width: 300,
                        child: DropdownButtonFormField<String>(
                          value: _estatController,
                          decoration: InputDecoration(
                            hintText: 'Selecciona una opció',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          items: <String>[
                            'Pre-Diàlisi',
                            'Diàlisi',
                            'Trasplantat'
                          ]
                              .map((String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ))
                              .toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _estatController = newValue!;
                            });
                          },
                          validator: (value) => value == null
                              ? 'Si us plau, selecciona una opció'
                              : null,
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
                                // Validar el formulari
                                if (_formKey.currentState!.validate()) {
                                  determinarTipusC();
                                // Guardar les dades mèdiques en el Firestore
                                  guardarDatosMedicos(
                                      widget.userId,
                                      _selectedDiabetic ?? '',
                                      _selectedHipertens ?? '',
                                      _selectedPacientExpert ?? '',
                                      _selectedActivitatFisica ?? '',
                                      _selectedEstadio ?? '',
                                      '${_alcadaController.text} m',
                                      '${_pesController.text} kg',
                                      _estatController ?? '',
                                      _selectedTipusC ?? '');
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Color.fromARGB(197, 4, 0, 255)),
                              ),
                              child: Text(
                                'Enviar',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
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
