import 'package:flutter/material.dart';
import 'package:kidneyproject/components/button.dart';
import 'package:kidneyproject/components/square_tile.dart';
import 'package:kidneyproject/components/textfield.dart';
import 'package:kidneyproject/components/btn_registrar.dart';
import 'package:kidneyproject/pages/sign_in_page.dart';

class SignUpTypePage extends StatelessWidget {
  SignUpTypePage({Key? key}) : super(key: key);

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  
  void signUserIn() {

  }

  void navigateToSignInPage(BuildContext context) {
    Navigator.push(
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

              TextFieldWidget(
                controller: nameController,
                hintText: 'Nom',
                obscureText: false,
              ),

              const SizedBox(height: 15),

              TextFieldWidget(
                controller: usernameController,
                hintText: 'Correu Electronic',
                obscureText: false,
              ),

              const SizedBox(height: 15),

              TextFieldWidget(
                controller: passwordController,
                hintText: 'Constrasenya',
                obscureText: true,
              ),

              const SizedBox(height: 15),

              //button inicia sessio
              btn_registrar(
                onTap: signUserIn,
              ),

              const SizedBox(height: 15),

              //Oblidat Contrasenya
              GestureDetector(
                onTap: () {
                  navigateToSignInPage(context);
                },
                child: Text(
                  'Ja tens compte? Inicia Sessió',
                  style: TextStyle(
                    color: Colors.grey[800],
                    decoration: TextDecoration.underline,
                  ),
                ),
              )

              /*const SizedBox(height: 15),

              //Oblidat Contrasenya
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'O continuar amb',
                        style: TextStyle(color: Colors.grey[700])
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
               

              const SizedBox(height: 15),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SquareTile(imagePath: 'lib/images/apple.png'),
                  SizedBox(width: 30),

                  SquareTile(imagePath: 'lib/images/google.png')
                ],
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
