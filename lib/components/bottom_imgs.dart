import 'package:flutter/material.dart';

class BottomImgs extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;


  const BottomImgs({super.key, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        padding: EdgeInsets.all(1),
        child: Image.asset(
          imagePath,
          height: 120,
        ),
      ),
    );
  }
}
