import 'package:flutter/material.dart';
import 'package:kidneyproject/components/button.dart';
import 'package:flutter/material.dart';
import 'package:kidneyproject/components/btn_iniciSessio.dart';
import 'package:kidneyproject/components/btn_registrar.dart';
import 'package:kidneyproject/pages/sign_in_page.dart';
import 'package:kidneyproject/pages/sign_Up_Choose.dart';

class Help extends StatelessWidget {
  const Help({Key? key}) : super(key: key);

  void iniciS(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );
  }

  void register(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpChoose()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: const SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              //text inicia sessio
              const Text(
                'Ajuda',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
