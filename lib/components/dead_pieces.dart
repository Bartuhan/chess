import 'package:flutter/material.dart';

class DeadPieces extends StatelessWidget {
  const DeadPieces({super.key, required this.imagePath, required this.isWhite});
  final String imagePath;
  final bool isWhite;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      color: isWhite ? Colors.white : Colors.black,
    );
  }
}
