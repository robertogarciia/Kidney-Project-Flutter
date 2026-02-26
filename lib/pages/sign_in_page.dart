import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _contrasenyaController.dispose();
    super.dispose();
  }

  Future<void> signUserIn(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _contrasenyaController.text.trim(),
      );

      String userId = userCredential.user!.uid;

      // 🔎 Obtener tipo de usuario desde Firestore
      final tipoDoc = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userId)
          .collection('tipusDeUsuario')
          .doc('tipus')
          .get();

      final data = tipoDoc.data();
      String tipo = data?['tipo'] ?? '';

      bool isFamiliar = tipo == 'Familiar';
      String? relatedPatientId;

      // Si es familiar, buscamos el paciente relacionado directamente
      if (isFamiliar) {
        final relacionSnap = await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(userId)
            .collection('relacionFamiliarPaciente')
            .limit(1)
            .get();

        if (relacionSnap.docs.isNotEmpty) {
          final dniPaciente = relacionSnap.docs.first['DniPaciente'];

          // Buscar el userId del paciente a partir del DNI
          final usersSnapshot =
              await FirebaseFirestore.instance.collection('Usuarios').get();

          for (var userDoc in usersSnapshot.docs) {
            final personalSnapshot = await userDoc.reference
                .collection('dadesPersonals')
                .doc('dades')
                .get();

            if (personalSnapshot.exists) {
              final personalData = personalSnapshot.data();
              if (personalData?['Dni'] == dniPaciente) {
                relatedPatientId = userDoc.id;
                break;
              }
            }
          }
        }
      }

      Widget targetPage;

      if (tipo == 'Pacient' || tipo == 'Familiar') {
        targetPage = MenuPrincipal(
          userId: userId,
          isFamiliar: isFamiliar,
          relatedPatientId: relatedPatientId,
        );
      } else {
        targetPage = TipusUsuari(userId: userId);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => targetPage),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Error al iniciar sessió";

      if (e.code == 'user-not-found') {
        message = 'No existeix cap usuari amb aquest correu.';
      } else if (e.code == 'wrong-password') {
        message = 'Contrasenya incorrecta.';
      } else if (e.code == 'invalid-email') {
        message = 'El correu electrònic no és vàlid.';
      } else if (e.code == 'user-disabled') {
        message = 'Aquest usuari està deshabilitat.';
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() => _isLoading = false);
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
    return false;
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
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    Image.asset('assets/images/logoKNP_WT.png', height: 300),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
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
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscured
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : BtnIniciSessio(
                            onTap: () => signUserIn(context),
                          ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () => navigateToRegistrationPage(context),
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
      ),
    );
  }
}
