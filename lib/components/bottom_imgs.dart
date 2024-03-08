import 'package:flutter/material.dart';

class BottomImgs extends StatelessWidget {
  final String imagePath;
  const BottomImgs({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(1),
      child: Image.asset(
        imagePath,
        height: 120,
      ),
    );
  }
}
