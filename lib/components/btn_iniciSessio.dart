import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 800, vertical: 10),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 40, 21, 245),
        borderRadius: BorderRadius.circular(8)
      ),
      child: const Center(
        child: Text(
          "Incia Sessió",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        )
      ),
    );
  }
} 
