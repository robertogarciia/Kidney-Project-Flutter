import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:kidneyproject/components/btn_iniciSessio.dart';
import 'package:kidneyproject/pages/login_page.dart';
import 'package:kidneyproject/pages/menu_principal.dart';
import 'package:kidneyproject/pages/sign_up_type_page.dart';
import 'package:kidneyproject/pages/tipus_usuari.dart';

class SignIn extends StatefulWidget {
  SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> with WidgetsBindingObserver {
  final _emailController = TextEditingController();
  final _contrasenyaController = TextEditingController();
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Detecta cuando la app vuelve al primer plano y reinicia la página
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignIn()),
      );
    }
  }

  Future<void> signUserIn(BuildContext context) async {
    final QuerySnapshot<Map<String, dynamic>> query =
    await FirebaseFirestore.instance.collection('Usuarios').get();

    var bytes = utf8.encode(_contrasenyaController.text);
    var digest = sha256.convert(bytes);
    var hashedPasswordToCheck = digest.toString();

    bool credentialsMatch = false;
    String userId = '';

    for (QueryDocumentSnapshot<Map<String, dynamic>> documento in query.docs) {
      Map<String, dynamic> usuario = documento.data();
      if (usuario['Email'] == _emailController.text &&
          usuario['Contrasenya'] == hashedPasswordToCheck) {
        credentialsMatch = true;
        userId = documento.id;
        break;
      }
    }

    if (credentialsMatch) {
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
                  var userDoc = FirebaseFirestore.instance.collection('Usuarios').doc(userId);
                  var documentSnapshot = await userDoc.collection('tipusDeUsuario').doc('tipus').get();

                  if (documentSnapshot.exists && documentSnapshot['tipo'] != null) {
                    String tipo = documentSnapshot['tipo'];
                    Widget targetPage = (tipo == 'Pacient' || tipo == 'Familiar')
                        ? MenuPrincipal(userId: userId)
                        : TipusUsuari(userId: userId);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => targetPage),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TipusUsuari(userId: userId)),
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
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Inici de sessió fallit'),
            content: Text('El correu electrònic o la contrasenya són incorrectes.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
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

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    Image.asset('lib/images/logoKNP_WT.png', height: 300),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Correu Electrònic',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _contrasenyaController,
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        hintText: 'Contrasenya',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    BtnIniciSessio(onTap: () => signUserIn(context)),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () => navigateToRegistrationPage(context),
                      child: Text(
                        'Si no tens un compte, registra\t!',
                        style: TextStyle(color: Colors.grey[800], decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}