import 'package:flutter/material.dart';
import 'package:kidneyproject/components/btn_iniciSessio.dart';
import 'package:kidneyproject/components/textfield.dart';
import 'package:kidneyproject/pages/sign_Up_Choose.dart';


class SignIn extends StatelessWidget {
  SignIn({Key? key}) : super(key: key);

  //text editar controlladors
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() {

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
              //text inicia sessio
              const Text(
                'Inici de sessió',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),

              //logo
              Image.asset(
                'lib/images/logoKNP_WT.png',
                height: 300,
              ),

              //Introduccio Correu
              TextFieldWidget(
                controller: usernameController,
                hintText: 'Correu Electronic',
                obscureText: false,
              ),

              const SizedBox(height: 15),

              //Introduccio Contrasenya
              TextFieldWidget(
                controller: passwordController,
                hintText: 'Contrasenya',
                obscureText: true,
              ),

              const SizedBox(height: 15),

              //Oblidat Contrasenya
              Text(
                'Has oblidat la contrasenya?',
                style: TextStyle(color: Colors.grey[800]),
                ),

              const SizedBox(height: 15),

              //button inicia sessio
              btn_iniciSessio(
                onTap: signUserIn,
              ),

              const SizedBox(height: 15),

              //Oblidat Contrasenya
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

              //text no tens compte

              //button registrat
            ],
          ),
        ),
      ),
    );
  }
}