import 'package:flutter/material.dart';

class MidleImgs extends StatelessWidget {
  final String imagePath;
  const MidleImgs({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(1),
      child: Image.asset(
        imagePath,
        height: 130,
      ),
    );
  }
}
