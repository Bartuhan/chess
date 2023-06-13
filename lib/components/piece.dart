enum ChessPieceType { pawn, rook, king, queen, knight, bishop }

class ChessPieces {
  final ChessPieceType type;
  final bool isWhite;
  final String imagePath;

  ChessPieces(
      {required this.type, required this.isWhite, required this.imagePath});
}
