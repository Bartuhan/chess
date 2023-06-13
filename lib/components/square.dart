import 'package:chess/components/piece.dart';
import 'package:chess/values/colors.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  const Square(
      {super.key,
      required this.isWhite,
      this.piece,
      required this.isSeleccted,
      this.onTap,
      required this.isValidMove});

  final ChessPieces? piece;
  final bool isWhite, isSeleccted;
  final void Function()? onTap;
  final bool isValidMove;

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    //if selected , square is green
    if (isSeleccted) {
      squareColor = Colors.green;
    }

    // Move routs
    else if (isValidMove) {
      squareColor = Colors.green.shade300;
    }

    // otherwise, its white or black
    else {
      squareColor = isWhite ? foreGroundColor : backGroundColor;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        margin: EdgeInsets.all(isValidMove ? 5 : 0),
        child: piece != null
            ? Image.asset(
                piece!.imagePath,
                color: piece!.isWhite ? Colors.white : Colors.black,
              )
            : null,
      ),
    );
  }
}
