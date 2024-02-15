import 'package:flutter/material.dart';

class button extends StatelessWidget {
  final String buttonText;

  const button(child, {Key? key, required this.buttonText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 800.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 59, 25, 212),
        
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Text("Login", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 20 , fontFamily: 'Roboto')),
      ),
    );
  }
}
