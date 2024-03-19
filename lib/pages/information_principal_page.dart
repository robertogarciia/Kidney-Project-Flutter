import 'package:flutter/material.dart';

class Information extends StatefulWidget {
  Information({Key? key}) : super(key: key);
  
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
                'Information',
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