import 'package:flutter/material.dart';

class MidleImgs extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const MidleImgs({Key? key, required this.imagePath, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        padding: EdgeInsets.all(1),
        child: Image.asset(
          imagePath,
          height: 130,
        ),
      ),
    );
  }
}
