import 'package:flutter/material.dart';
import 'package:kidneyproject/components/btn_iniciSessio.dart';
import 'package:kidneyproject/components/textfield.dart';
import 'package:kidneyproject/pages/sign_up_type_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:kidneyproject/pages/tipus_usuari.dart';

class SignIn extends StatelessWidget {
  SignIn({Key? key}) : super(key: key);

  final _emailController = TextEditingController();
  final _contrasenyaController = TextEditingController();

  Future<List<Map<String, dynamic>>> getUsuarios() async {
    List<Map<String, dynamic>> usuarios = [];
    QuerySnapshot query = await FirebaseFirestore.instance.collection('Usuarios').get();

    for (QueryDocumentSnapshot documento in query.docs) {
      usuarios.add(documento.data() as Map<String, dynamic>);
    }

    return usuarios;
  }

  Future<void> signUserIn(BuildContext context) async {
    final usuarios = await getUsuarios();

    // Encripta la contrasenya i comparara amb contrasenyas almacenades
    var bytes = utf8.encode(_contrasenyaController.text);
    var digest = sha256.convert(bytes);
    var hashedPasswordToCheck = digest.toString();

    // Verificar si existeix un usuario amb el correu i la contrasenya 
    bool credentialsMatch = false;
    for (Map<String, dynamic> usuario in usuarios) {
      if (usuario['Email'] == _emailController.text && usuario['Contrasenya'] == hashedPasswordToCheck) {
        credentialsMatch = true;
        break;
      }
    }

 if (credentialsMatch) {
  // Inici de sessió exitos
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Inici de Sessió Exitos'),
        content: Text('Benvingut!'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();

              // Navegar a la pantalla SignUpTypePage después de cerrar el diálogo
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TipusUsuari()),
              );
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
 else {
      // Error: Credencials incorrectas
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Inici de Sessió Fallit'),
            content: Text('El correu electrònic o la contrasenya són incorrectes. Per favor, torna a intentar-ho.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void navigateToRegistrationPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpTypePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              const Text(
                'Inici de sessió',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Image.asset(
                'lib/images/logoKNP_WT.png',
                height: 300,
              ),
              TextFieldWidget(
                controller: _emailController,
                hintText: 'Correu Electrònic',
                obscureText: false,
              ),
              const SizedBox(height: 15),
              TextFieldWidget(
                controller: _contrasenyaController,
                hintText: 'Contrasenya',
                obscureText: true,
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  // Implementar lógica  restablecer contraseña 
                },
                child: Text(
                  'Has oblidat la contrasenya?',
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ),
              const SizedBox(height: 15),
              btn_iniciSessio(
                onTap: () => signUserIn(context),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  navigateToRegistrationPage(context);
                },
                child: Text(
                  'No tens compte? Registrat',
                  style: TextStyle(
                    color: Colors.grey[800],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
