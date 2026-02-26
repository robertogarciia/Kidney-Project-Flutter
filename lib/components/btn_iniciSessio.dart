import 'package:flutter/material.dart';

class BtnIniciSessio extends StatelessWidget {
  final Function()? onTap;
  final EdgeInsetsGeometry margin;

  const BtnIniciSessio({
    Key? key,
    required this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 25),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity, // Ancho máximo igual al ancho de la pantalla
        child: Container(
          padding: const EdgeInsets.all(15),
          margin: margin,
          decoration: BoxDecoration(
            color: const Color(0xFF403DF3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              "Inicia sessió",
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
