import 'package:flutter/material.dart';
import 'package:kidneyproject/pages/sign_in_page.dart';
import 'package:kidneyproject/pages/sign_Up_Choose.dart';

class Diets extends StatelessWidget {
  const Diets({Key? key}) : super(key: key);

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
              SizedBox(
                height: 20,
              ),
              //text inicia sessio
              Text(
                'Dietes',
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
