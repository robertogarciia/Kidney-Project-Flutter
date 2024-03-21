import 'package:flutter/material.dart';
import 'package:kidneyproject/components/textfield.dart';

void main() {
  runApp(Formulario4());
}

class Formulario4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dades Familiars',
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
  TextEditingController _emailController = TextEditingController();
  TextEditingController _contrasenyaController = TextEditingController();
  TextEditingController _repetirContrasenyaController = TextEditingController();
  TextEditingController _telefonmovilController = TextEditingController();
  TextEditingController _adrecaController = TextEditingController();
  TextEditingController _poblacioController = TextEditingController();
  TextEditingController _codiPostalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dades Familiars'),
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
                controller: _emailController,
                hintText: 'Email',
                obscureText: false,
              ),
              SizedBox(height: 20),
              TextFieldWidget(
                controller: _contrasenyaController,
                hintText: 'Contrasenya',
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextFieldWidget(
                controller: _repetirContrasenyaController,
                hintText: 'Repeteix la Contrasenya',
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextFieldWidget(
                controller: _telefonmovilController,
                hintText: 'Telefon mòbil',
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextFieldWidget(
                controller: _adrecaController,
                hintText: 'Adreça',
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextFieldWidget(
                controller: _poblacioController,
                hintText: 'Població',
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextFieldWidget(
                controller: _codiPostalController,
                hintText: 'Codi postal',
                obscureText: true,
              ),


              SizedBox(height: 20),],),),

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