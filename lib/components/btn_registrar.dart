import 'package:flutter/material.dart';

class btn_registrar extends StatelessWidget {
  final Function()? onTap;

  const btn_registrar({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity, // Ancho máximo igual al ancho de la pantalla
        child: Container(
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            color: const Color(0xFF403DF3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              "Registrar-se",
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
