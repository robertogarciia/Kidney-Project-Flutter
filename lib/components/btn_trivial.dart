import 'package:flutter/material.dart';

class TrivialButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final bool isCorrect;
  final Color defaultButtonColor; // Color del botón por defecto

  const TrivialButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.isCorrect,
    required this.defaultButtonColor, // Agregar el color del botón por defecto
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color buttonColor = defaultButtonColor; // Color por defecto

    return GestureDetector(
      onTap: () {
        if (onPressed != null) {
          // Cambiar el color del botón según sea correcto o incorrecto
          buttonColor = isCorrect ? Colors.green : Colors.red;
          onPressed!();
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
