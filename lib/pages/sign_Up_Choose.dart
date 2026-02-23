import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:kidneyproject/components/btn_registrar.dart';
import 'package:kidneyproject/pages/sign_in_page.dart';

class SignUpChoose extends StatefulWidget {
  const SignUpChoose({Key? key}) : super(key: key);

  @override
  State<SignUpChoose> createState() => _SignUpChooseState();
}

class _SignUpChooseState extends State<SignUpChoose> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  bool isLoading = false;

  // 🔐 Password validation variables
  bool showPasswordRestrictions = false;
  bool hasUpperCase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;
  bool hasMinLength = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void validatePassword(String password) {
    setState(() {
      hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      hasNumber = password.contains(RegExp(r'[0-9]'));
      hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      hasMinLength = password.length >= 6;
    });
  }

  // 🔥 REGISTER CON FIREBASE AUTH
  Future<void> registerUser() async {
    // 🚫 Bloquear si no cumple requisitos
    if (!hasUpperCase || !hasNumber || !hasSpecialChar || !hasMinLength) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Contrasenya invàlida'),
          content: const Text(
            'La contrasenya ha de complir tots els requisits indicats.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Acceptar'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('Usuarios').doc(uid).set({
        'Email': emailController.text.trim(),
        'Nombre': nameController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(uid)
          .collection('tipusDeUsuario')
          .doc('tipus')
          .set({
        'tipo': null,
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Registre completat'),
          content: const Text('Usuari creat correctament!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignIn()),
                );
              },
              child: const Text('OK'),
            )
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Error al registrar";

      if (e.code == 'email-already-in-use') {
        message = 'Aquest correu ja està registrat.';
      } else if (e.code == 'weak-password') {
        message = 'La contrasenya és massa dèbil.';
      } else if (e.code == 'invalid-email') {
        message = 'El correu electrònic no és vàlid.';
      }

      showDialog(
        context: context,
        barrierDismissible: false, // opcional: evita cerrar tocando fuera
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 🔥 Cierra el alert
              },
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void navigateToSignInPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 30),

                const Text(
                  'Registra\'t',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Image.asset(
                  'assets/images/logoKNP_WT.png',
                  height: 250,
                ),

                const SizedBox(height: 20),

                // Nombre
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Nom complet',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'Correu electrònic',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    onChanged: (value) {
                      showPasswordRestrictions = true;
                      validatePassword(value);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Contrasenya',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // 🔐 RESTRICCIONES VISUALES
                if (showPasswordRestrictions)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (passwordController.text.isEmpty)
                          const Text(
                            'Si us plau, ingressa una contrasenya',
                            style: TextStyle(color: Colors.red),
                          ),
                        Text(
                          'Al menys una majúscula: ${hasUpperCase ? '✔' : '❌'}',
                          style: TextStyle(
                            color: hasUpperCase ? Colors.green : Colors.red,
                          ),
                        ),
                        Text(
                          'Al menys un número: ${hasNumber ? '✔' : '❌'}',
                          style: TextStyle(
                            color: hasNumber ? Colors.green : Colors.red,
                          ),
                        ),
                        Text(
                          'Al menys un caràcter especial: ${hasSpecialChar ? '✔' : '❌'}',
                          style: TextStyle(
                            color: hasSpecialChar ? Colors.green : Colors.red,
                          ),
                        ),
                        Text(
                          'Longitud mínima de 6 caràcters: ${hasMinLength ? '✔' : '❌'}',
                          style: TextStyle(
                            color: hasMinLength ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                isLoading
                    ? const CircularProgressIndicator()
                    : BtnRegistrar(onTap: registerUser),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: navigateToSignInPage,
                  child: const Text('Ja tens compte? Inicia sessió'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
