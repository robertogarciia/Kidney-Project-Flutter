import 'package:flutter/material.dart';
import 'package:kidneyproject/components/btn_iniciSessio.dart';
import 'package:kidneyproject/components/textfield.dart';

class SignIn extends StatelessWidget {
  SignIn({Key? key}) : super(key: key);

  //text editar controlladors
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[

              const SizedBox(
                height: 50,
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

              //Introduccio Contrasenya
              TextFieldWidget(
                controller: passwordController,
                hintText: 'Contrasenya',
                obscureText: true,
              ),

              //Oblidat Contrasenya
              Text(
                'Has oblidat la contrasenya?',
                style: TextStyle(color: Colors.grey[800]),
                ),

              //button inicia sessio
              MyButton(),

              //text no tens compte

              //button registrat
            ],
          ),
        ),
      ),
    );
  }
}