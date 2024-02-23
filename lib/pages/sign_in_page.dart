import 'package:flutter/material.dart';
import 'package:kidneyproject/components/btn_iniciSessio.dart';
import 'package:kidneyproject/components/textfield.dart';
import 'package:kidneyproject/pages/sign_Up_Choose.dart';
import 'package:kidneyproject/pages/tipus_usuari.dart';

class SignIn extends StatelessWidget {
  SignIn({Key? key}) : super(key: key);

  //text editar controlladors
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() {

  }

  void navigateToTipusUsuari(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TipusUsuari()),
    );
  }

  void navigateToRegistrationPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpChoose()),
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
                controller: usernameController,
                hintText: 'Correu Electronic',
                obscureText: false,
              ),

              const SizedBox(height: 15),

              TextFieldWidget(
                controller: passwordController,
                hintText: 'Contrasenya',
                obscureText: true,
              ),

              const SizedBox(height: 15),

              Text(
                'Has oblidat la contrasenya?',
                style: TextStyle(color: Colors.grey[800]),
              ),

              const SizedBox(height: 15),

              BtnIniciSessio(
                onTap: () {
                  navigateToTipusUsuari(context);
                },
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