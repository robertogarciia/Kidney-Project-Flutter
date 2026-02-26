import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'sign_in_page.dart';

/// BOTÓN REGISTRAR PERSONALIZADO
class BtnRegistrar extends StatelessWidget {
  final VoidCallback onTap;

  const BtnRegistrar({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pinkAccent,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Text(
        'Registrar',
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

/// PANTALLA DE REGISTRO
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

  // 🔐 Validación de contraseña
  bool showPasswordRestrictions = false;
  bool hasUpperCase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;
  bool hasMinLength = false;
  bool showPassword = false; // Mostrar/ocultar contraseña

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

  Future<void> registerUser() async {
    if (isLoading) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Dades incompletes'),
          content: const Text('Completa nom, correu i contrasenya.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Acceptar')),
          ],
        ),
      );
      return;
    }

    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Correu invalid'),
          content: const Text('Introdueix un correu electronic valid.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Acceptar')),
          ],
        ),
      );
      return;
    }

    if (!hasUpperCase || !hasNumber || !hasSpecialChar || !hasMinLength) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Contrasenya invalida'),
          content: const Text(
              'La contrasenya ha de complir tots els requisits indicats.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Acceptar')),
          ],
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    UserCredential? userCredential;

    try {
      userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('Usuarios').doc(uid).set({
        'Email': email,
        'Nombre': name,
        'createdAt': Timestamp.now(),
      });

      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(uid)
          .collection('tipusDeUsuario')
          .doc('tipus')
          .set({'tipo': null});

      if (!mounted) return;
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
      String message = 'Error al registrar';

      if (e.code == 'email-already-in-use') {
        message = 'Aquest correu ja esta registrat.';
      } else if (e.code == 'weak-password') {
        message = 'La contrasenya es massa debil.';
      } else if (e.code == 'invalid-email') {
        message = 'El correu electronic no es valid.';
      } else if (e.code == 'network-request-failed') {
        message = 'Error de connexio. Revisa la teva xarxa.';
      }

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar')),
          ],
        ),
      );
    } catch (e) {
      if (userCredential?.user != null) {
        try {
          await userCredential!.user!.delete();
        } catch (_) {}
      }

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'No sha pogut completar el registre. Torna-ho a provar.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar')),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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

                // Password amb ícono mostrar/ocultar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    onChanged: (value) {
                      showPasswordRestrictions = true;
                      validatePassword(value);
                      setState(() {}); // Per refrescar checkmarks
                    },
                    decoration: InputDecoration(
                      hintText: 'Contrasenya',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey[700],
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 🔐 RESTRICCIONS VISUALES
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

                // Botó registrar
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
