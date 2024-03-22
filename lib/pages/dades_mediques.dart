import 'package:flutter/material.dart';
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
  TextEditingController _estadioController = TextEditingController();
  TextEditingController _estatController = TextEditingController();
  TextEditingController _diabeticController = TextEditingController();
  TextEditingController _hipertensController = TextEditingController();
  TextEditingController _pacientExpertController = TextEditingController();
  TextEditingController _activitatFisicaController = TextEditingController();

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