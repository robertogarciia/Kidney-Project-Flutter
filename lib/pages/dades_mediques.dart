import 'package:flutter/material.dart';
import 'package:kidneyproject/components/listfield.dart';
import 'package:kidneyproject/components/textfield.dart';

void main() {
  runApp(Formulario3());
}

class Formulario3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dades Mediques',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Formulario(),
    );
  }
}

class Formulario extends StatefulWidget {
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Si el formulario es válido, muestra un diálogo de éxito.
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Éxito'),
                            content: Text('El formulario es válido'),
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