import 'package:flutter/material.dart';

class Diets extends StatefulWidget {
  Diets({Key? key}) : super(key: key);
  
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: const  SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
               SizedBox(
                height: 30,
              ),
              Text(
                'Diets',
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

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}