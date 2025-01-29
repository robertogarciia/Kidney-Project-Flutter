import 'package:flutter/material.dart';

class MidleImgs extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;
  final double width;
  final double height;

  const MidleImgs({
    Key? key,
    required this.imagePath,
    required this.onTap,
    this.width = 145,
    this.height = 145,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(1),
        child: Image.asset(
          imagePath,
          width: width,
          height: height,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
