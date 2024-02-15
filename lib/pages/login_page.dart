import 'package:flutter/material.dart';
import 'package:kidneyproject/components/button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

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

              const button(),

             const button(buttonText: 'Registra\'t'),
              //button registrat
            ],
          ),
        ),
      ),
    );s
  }
}
