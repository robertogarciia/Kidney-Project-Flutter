import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:kidneyproject/components/btn_iniciSessio.dart';
import 'package:kidneyproject/components/textfield.dart';
import 'package:kidneyproject/pages/menu_principal.dart';
import 'package:kidneyproject/pages/sign_up_type_page.dart';
import 'package:kidneyproject/pages/tipus_usuari.dart';

class SignIn extends StatelessWidget {
  SignIn({Key? key}) : super(key: key);

  final _emailController = TextEditingController();
  final _contrasenyaController = TextEditingController();

  // Future to handle user login
Future<void> signUserIn(BuildContext context) async {
  // Obtener los usuarios desde Firestore
  final QuerySnapshot<Map<String, dynamic>> query =
      await FirebaseFirestore.instance.collection('Usuarios').get();

  // Encriptar la contraseña
  var bytes = utf8.encode(_contrasenyaController.text);
  var digest = sha256.convert(bytes);
  var hashedPasswordToCheck = digest.toString();

  // Verificar si existe un usuario con el correo y la contraseña
  bool credentialsMatch = false;
  String userId = '';

  for (QueryDocumentSnapshot<Map<String, dynamic>> documento in query.docs) {
    Map<String, dynamic> usuario = documento.data();
    if (usuario['Email'] == _emailController.text &&
        usuario['Contrasenya'] == hashedPasswordToCheck) {
      credentialsMatch = true;
      userId = documento.id; // Obtener el ID del usuario
      break;
    }
  }

  // Si las credenciales coinciden
  if (credentialsMatch) {
    // Mostrar el diálogo de inicio exitoso
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Inici de sessió exitós'),
          content: Text('Benvingut/da!'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Consultar si el usuario tiene la subcolección 'tipusDeUsuario' y si 'tipus' existe
                var userDoc = FirebaseFirestore.instance.collection('Usuarios').doc(userId);

                // Verifica si el documento 'tipus' existe dentro de la subcolección 'tipusDeUsuario'
                var documentSnapshot = await userDoc.collection('tipusDeUsuario').doc('tipus').get();

                // Si el documento 'tipus' existe y contiene el campo 'tipo'
                if (documentSnapshot.exists && documentSnapshot['tipo'] != null) {
                  String tipo = documentSnapshot['tipo'];

                  // Imprimir el tipo de usuario en la consola
                  print('Tipo de usuario: $tipo');

                  // También podemos mostrar el tipo en un AlertDialog si lo deseamos
                 

                  // Redirigir según el tipo de usuario
                  Widget targetPage;
                  print('userId: $userId');
                  if (tipo == 'Pacient' || tipo == 'Familiar') {
                    targetPage = MenuPrincipal(userId: userId);
                  } else {
                    targetPage = TipusUsuari(userId: userId);
                  }

                  // Navegar a la página correspondiente
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MenuPrincipal(userId: userId),
                    ),
                  );
                } else {
                  // Si no existe el campo 'tipo' o no se encuentra el documento, redirigir a TipusUsuari
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TipusUsuari(userId: userId),
                    ),
                  );
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  } else {
    // Error: Credenciales incorrectas
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Inici de sessió fallit'),
          content: Text(
              'El correu electrònic o la contrasenya introduïts són incorrectes. Si us plau, torna a intentar-ho.'),
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



  // Navegar a la página de registro
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
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 30),
                  const Text(
                    'Inicia sessió',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Image.asset(
                    'lib/images/logoKNP_WT.png',
                    height: 300,
                  ),
                  const SizedBox(height: 15),
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
                      // Implementar lógica para restablecer contraseña
                    },
                    child: Text(
                      'Has oblidat la contrasenya?',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),
                  const SizedBox(height: 15),
                  BtnIniciSessio(onTap: () => signUserIn(context)),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () {
                      navigateToRegistrationPage(context);
                    },
                    child: Text(
                      'Si no tens un compte, registra\'t!',
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
        ),
      ),
    );
  }
}
