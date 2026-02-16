import 'package:flutter/material.dart';

class BtnGeneral extends StatelessWidget {
  final String buttonText;
  final Function()? onTap;
  final Color buttonColor; // New parameter for button color

  const BtnGeneral({
    Key? key,
    required this.buttonText,
    required this.onTap,
    this.buttonColor = const Color(0xFF403DF3), // Default color is the original blue
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity, // Full width of the screen
        child: Container(
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            color: buttonColor, // Use the button color passed in
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              buttonText,
              style: const TextStyle(
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
