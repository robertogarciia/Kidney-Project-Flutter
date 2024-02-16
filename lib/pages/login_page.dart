import 'package:flutter/material.dart';
import 'package:kidneyproject/components/btn_iniciSessio.dart';
import 'package:kidneyproject/components/btn_registrar.dart';
import 'package:kidneyproject/pages/sign_in_page.dart';
import 'package:kidneyproject/pages/sign_up_type_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  void iniciS(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );
  }

  void register(BuildContext context) {
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
                height: 20,
              ),
              //text inicia sessio
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

              const SizedBox( height: 30 ),

              //Introduccio Correu
              btn_iniciSessio(
                onTap: () {
                  iniciS(context);
                },
              ),

              const SizedBox( height: 15 ),

              Text(
                'Si no tens un compte, registrat!',
                style: TextStyle(color: Colors.grey[800]),
              ),

              const SizedBox( height: 15 ),

              btn_registrar(
                onTap: () {
                  register(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
