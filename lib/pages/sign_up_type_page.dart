import 'package:flutter/material.dart';
import 'package:kidneyproject/components/button.dart';
import 'package:kidneyproject/components/square_tile.dart';

class SignUpTypePage extends StatelessWidget {
  const SignUpTypePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: const SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              Text(
                'Registra\'t',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Button(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SquareTile(imagePath: 'lib/images/apple.png'),
                  const SizedBox(width: 60),

                  SquareTile(imagePath: 'lib/images/google.png')
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
