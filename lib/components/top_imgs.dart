import 'package:flutter/material.dart';

class TopImgs extends StatelessWidget {
  final String imagePath;
  const TopImgs({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(1),
      child: Image.asset(
        imagePath,
        height: 80,
      ),
    );
  }
}
