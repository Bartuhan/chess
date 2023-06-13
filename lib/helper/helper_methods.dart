bool isWhite(int index) {
  int x = index ~/ 8; // Burası bize Row kısmını verir
  int y = index % 8; // Burası ise column kısmını

  bool isWhite = (x + y) % 2 == 0;
  return isWhite;
}

bool isInBoard(int row, int col) {
  return row >= 0 && row < 8 && col >= 0 && col < 8;
}
