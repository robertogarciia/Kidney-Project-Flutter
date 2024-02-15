import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const TextFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    });
  

  @override
  Widget build(BuildContext context) {
     return Padding(
      padding: const EdgeInsets.symmetric(horizontal:800.0, vertical: 10.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            fillColor: Colors.grey.shade200,
            filled: true,
            hintText: hintText,
          ),
        ),
    );
  }
}
