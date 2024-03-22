import 'package:flutter/material.dart';
import 'package:kidneyproject/components/listfield.dart';
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
  String? _selectedEstat;
  String? _selectedDiabetic;
  String? _selectedHipertens;
  String? _selectedExpert;
  String? _selectedActivitatFisica;
  
  TextEditingController _estadioController = TextEditingController();
  TextEditingController _estatController = TextEditingController();
  TextEditingController _diabeticController = TextEditingController();
  TextEditingController _hipertensController = TextEditingController();
  TextEditingController _pacientExpertController = TextEditingController();
  TextEditingController _activitatFisicaController = TextEditingController();

  Future<void> guardarDatosMedicos(String userId, String alcada, String pes, String estadio, String estat, String diabetic, String hipertens, String pacientExpert, String activitatFisica) async {
    try {
      // Guardar los datos médicos en la colección 'dadesMediques' dentro del documento del usuario
      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userId)
          .collection('dadesMediques')
          .doc('dades')
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
        title: Text('Dades Mediques'),
      ),  
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xA6403DF3),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
              TextFieldWidget(
                controller: _alcadaController,
                hintText: 'Alçada',
                obscureText: false,
              ),
              SizedBox(height: 20),
              TextFieldWidget(
                controller: _pesController,
                hintText: 'Pes',
                obscureText: true,
              ),
              SizedBox(height: 20),
              Container(
                      height: 50,
                      width: 780,
                      child: ListField(
                        items: ['Sense estadio','Amb estadio'],
                        value: _selectedEstadio,
                        hintText: 'Selecciona una opción',
                        onChanged: (String? value) {
                          setState(() {
                            _selectedEstadio = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor selecciona una opción';
                          }
                          return null;
                        },
                      ),
                    ),
              SizedBox(height: 20),
              Container(
                      height: 50,
                      width: 780,
                      child: ListField(
                        items: ['Pre-diàlisis','...'],
                        value: _selectedEstat,
                        hintText: 'Selecciona una opción',
                        onChanged: (String? value) {
                          setState(() {
                            _selectedEstat = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor selecciona una opción';
                          }
                          return null;
                        },
                      ),
                    ),
              SizedBox(height: 20),
              Container(
                      child: Row(
                        children: [
                          Container(
                            height: 50,
                            width: 380,
                            child: ListField(
                              items: ['Si', 'No'],
                              value: _selectedDiabetic,
                              hintText: 'Diabetic',
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedDiabetic = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor selecciona una opción';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 20),
                          Container(
                            height: 50,
                            width: 380,
                            child: ListField(
                              items: ['Si', 'No'],
                              value: _selectedHipertens,
                              hintText: 'Hipertens',
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedHipertens = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor selecciona una opción';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
              SizedBox(height: 20),
              Container(
                      height: 50,
                      width: 780,
                      child: ListField(
                        items: ['Si','No'],
                        value: _selectedExpert,
                        hintText: 'Selecciona una opción',
                        onChanged: (String? value) {
                          setState(() {
                            _selectedExpert = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor selecciona una opción';
                          }
                          return null;
                        },
                      ),
                    ),
              SizedBox(height: 20),
              Container(
                      height: 50,
                      width: 780,
                      child: ListField(
                        items: ['Si','No'],
                        value: _selectedActivitatFisica,
                        hintText: 'Selecciona una opción',
                        onChanged: (String? value) {
                          setState(() {
                            _selectedActivitatFisica = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor selecciona una opción';
                          }
                          return null;
                        },
                      ),
                    ),
              SizedBox(height: 20),
              ],
              ),
                    TextFieldWidget(
                      controller: _alcadaController,
                      hintText: 'Alçada',
                      obscureText: false,
                    ),
                    SizedBox(height: 20),
                    TextFieldWidget(
                      controller: _pesController,
                      hintText: 'Pes',
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    TextFieldWidget(
                      controller: _estadioController,
                      hintText: 'Estadio',
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    TextFieldWidget(
                      controller: _estatController,
                      hintText: 'Estat',
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    TextFieldWidget(
                      controller: _diabeticController,
                      hintText: 'Diabetic',
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    TextFieldWidget(
                      controller: _hipertensController,
                      hintText: 'Hipertens',
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    TextFieldWidget(
                      controller: _pacientExpertController,
                      hintText: 'Pacient expert',
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    TextFieldWidget(
                      controller: _activitatFisicaController,
                      hintText: 'Activitat Fisica',
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Si el formulario es válido, guardar los datos médicos
                      guardarDatosMedicos(
                        widget.userId,
                        _alcadaController.text,
                        _pesController.text,
                        _estadioController.text,
                        _estatController.text,
                        _diabeticController.text,
                        _hipertensController.text,
                        _pacientExpertController.text,
                        _activitatFisicaController.text,
                      );

                      // Mostrar un diálogo de éxito
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Éxito'),
                            content: Text('Los datos médicos han sido guardados con éxito'),
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
        ),
      ),
    );
  }
}
