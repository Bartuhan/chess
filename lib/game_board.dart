import 'dart:io';

import 'package:chess/components/piece.dart';
import 'package:chess/components/square.dart';
import 'package:chess/helper/helper_methods.dart';
import 'package:chess/values/colors.dart';
import 'package:flutter/material.dart';

import 'components/dead_pieces.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // A 2-dimensional list representing the chessboard
  // with each position possibly containing a chess piece
  late List<List<ChessPieces?>> board;

  @override
  void initState() {
    _initializeBoard();
    super.initState();
  }

  // The currrent selected pieces
  // if no pieces is selected this is null
  ChessPieces? selectedPiece;

  // The row index of the selected pieces ,
  // Default value -1 indicated no pieces currently selected
  int selectedRow = -1;

  // The col index of the selected pieces ,
  // Default value -1 indicated no pieces currently selected
  int selectedCol = -1;

  // A list of valid moves for the currently selected piece
  // each move is represented as a list with 2 elements : row and col
  List<List<int>> validMoves = [];

  //A list of white pieces that have been taken by the black player
  List<ChessPieces> whitePiecesTaken = [];

  //A list of white pieces that have been taken by the white player
  List<ChessPieces> blackPiecesTaken = [];

  // A boolean to indicate whose turn it is
  bool isWhiteTurn = true;

  // initial position of kings (Keep track of this to make it easier later to see if king is check)
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  //initialize board
  void _initializeBoard() {
    List<List<ChessPieces?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    /////////////// Place Pawns

    for (int i = 0; i < 8; i++) {
      //Black Pawns
      newBoard[1][i] = ChessPieces(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: "assets/img/pawn.png");

      // White Pawns
      newBoard[6][i] = ChessPieces(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: "assets/img/pawn.png");
    }

    /////////////// Place Rooks

    // Black Rooks
    newBoard[0][0] = ChessPieces(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: "assets/img/rook.png");

    newBoard[0][7] = ChessPieces(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: "assets/img/rook.png");

    //White Rooks
    newBoard[7][0] = ChessPieces(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: "assets/img/rook.png");

    newBoard[7][7] = ChessPieces(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: "assets/img/rook.png");

    /////////////// Place Bishops

    // Black Bishops
    newBoard[0][5] = ChessPieces(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: "assets/img/bishop.png");

    newBoard[0][2] = ChessPieces(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: "assets/img/bishop.png");

    //White Bishops

    newBoard[7][2] = ChessPieces(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: "assets/img/bishop.png");

    newBoard[7][5] = ChessPieces(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: "assets/img/bishop.png");

    /////////////// Place Knights

    // Black Knights
    newBoard[0][1] = ChessPieces(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: "assets/img/knight.png");

    newBoard[0][6] = ChessPieces(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: "assets/img/knight.png");

    // White Knights
    newBoard[7][1] = ChessPieces(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: "assets/img/knight.png");
    newBoard[7][6] = ChessPieces(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: "assets/img/knight.png");

    /////////////// Place King
    // Black King
    newBoard[0][4] = ChessPieces(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: "assets/img/king.png");
    // White King
    newBoard[7][4] = ChessPieces(
        type: ChessPieceType.king,
        isWhite: true,
        imagePath: "assets/img/king.png");

    /////////////// Place Queen
    // Black King
    newBoard[0][3] = ChessPieces(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: "assets/img/queen.png");
    // White King
    newBoard[7][3] = ChessPieces(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: "assets/img/queen.png");

    board = newBoard;
  }

  // User selected a pieces
  void pieceSelected(int row, int col) {
    setState(() {
      // No piece has been selected yet , this is the first selection
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }

      //There is a piece already selected , but user can select anodger one of their pieces
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }

      // İf there is a piece selected and user taps on a square is a valid move  move there
      else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      // if  a piece is selected  calculate its valid moves
      validMoves =
          calculateRealValidMove(selectedRow, selectedCol, selectedPiece, true);
    });
  }

  // Calculate Raw valid moves
  List<List<int>> calculateRawValidMove(int row, int col, ChessPieces? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }

    // Diffrent direction based on their color
    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:

        // pawns can move forvard if the square is not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        // pawns can move 2 squares forvard if they are at their initial position
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        // pawns can kill diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }

        break;
      case ChessPieceType.bishop:

        // Diagonal directions

        var directions = [
          [-1, -1], // Up Left
          [-1, 1], // Up Right
          [1, -1], // Down Left
          [1, 1] // Down Right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // Kill
              }
              break; //  Broke the loop
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
        // all eight possible L shapes the knight can move
        var knightMoves = [
          [-2, -1], // Up 2 Left 1
          [-2, 1], // Up 2 Right 1
          [-1, -2], // Up 1  Left 2
          [-1, 2], // Up 1 Right 2
          [1, -2], // Down 1 Left 2
          [1, 2], // Down 1 Right 2
          [2, -1], // Down 2 Left 1
          [2, 1], // Down 2 Right 1
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;
      case ChessPieceType.rook:
        // Horizontal and verticcal directions
        var directions = [
          [-1, 0], // Up
          [1, 0], //Down
          [0, -1], //Left
          [0, 1] //Right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // Kill
              }
              break; //  Broke the loop
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.queen:
        // All eight direction : Up , Down , Left , Right
        var directions = [
          [-1, 0], // Up
          [1, 0], // Down
          [0, -1], // Left
          [0, 1], // Right
          [-1, -1], // Up Left
          [-1, 1], // Up Right
          [1, -1], // Down Left
          [1, 1], // Down Right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // Kill
              }
              break; //  Broke the loop
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.king:

        // All eight direction : Up , Down , Left , Right
        var directions = [
          [-1, 0], // Up
          [1, 0], // Down
          [0, -1], // Left
          [0, 1], // Right
          [-1, -1], // Up Left
          [-1, 1], // Up Right
          [1, -1], // Down Left
          [1, 1], // Down Right
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            break;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // Kill
            }
            continue; //blocked
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      default:
    }
    return candidateMoves;
  }

  // Calculate Real valid moves
  List<List<int>> calculateRealValidMove(
      int row, int col, ChessPieces? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMove(row, col, piece);

    // after generating all candidate moves, filter oout any that would result in a check
    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];

        // This will simulate the future move to see if its safe
        if (simulatedMoveInSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }

  // Move the Piece
  void movePiece(int newRow, int newCol) {
    // if the new spot  has an enemy pieces
    if (board[newRow][newCol] != null) {
      // add the captured piece to the appropriate list
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    // Check if the piece being moved in a king
    if (selectedPiece!.isWhite) {
      whiteKingPosition = [newRow, newCol];
    } else {
      blackKingPosition = [newRow, newCol];
    }

    //Move The Piece and Clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // Clear The Selection

    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // See if any kings under attack
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    // Check if its checkmate
    if (isCheckMate(isWhiteTurn)) {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: const Text("CheckMate !"), actions: [
          // Play again Button
          TextButton(
            onPressed: resetGame,
            child: const Text("Play Again"),
          ),
        ]),
      );
    }

    // Change Turns
    isWhiteTurn = !isWhiteTurn;
  }

  // Is king in Check
  bool isKingInCheck(bool isWhiteKing) {
    // Get the position of the king
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateRealValidMove(i, j, board[i][j], false);

        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  // Simulate a future move to see if its safe (doesnt put your own king under attack)
  bool simulatedMoveInSafe(
      ChessPieces piece, int startRow, int startCol, int endRow, int endCol) {
    // Save the current board state
    ChessPieces? orginalDestinationPiece = board[endRow][endCol];

    // If the piece is the king, save its current position and update to the new one
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;

      // Update  king position
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    // Simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // Check if our own king under attack
    bool kingInCheck = isKingInCheck(piece.isWhite);

    // Restore board to orginal state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = orginalDestinationPiece;

    // if the piece was the king , restore it orginal position
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }

    // if king is check = true , means its not safe move = false.
    return !kingInCheck;
  }

  // Its Check Mate ?
  bool isCheckMate(bool isWhiteKing) {
    // if the king is not in check , then its not checkmate
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    // if there is al least one legal move for any of the player's pieces , then its not checkmate
    for (var i = 0; i < 8; i++) {
      for (var j = 0; j < 8; i++) {
        // skip empty squares and pieces of the odher color
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculateRealValidMove(i, j, board[i][j], true);

        // if this piece has any valid moves, then it's not checkmate
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    // if none of above conditions are met , then there are no legal moves left to make

    // its checkmate
    return true;
  }

  //Reset Game
  void resetGame() {
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      body: Column(
        children: [
          //////////// White Pieces taken
          Expanded(
            child: GridView.builder(
              itemCount: whitePiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPieces(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
            ),
          ),

          // Game Status
          Text(checkStatus ? "Check!" : "",
              style:
                  const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),

          //////////// Chess Board
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) {
                int row = index ~/ 8;
                int col = index % 8;

                // check if this square is selected
                bool isSelected = selectedRow == row && selectedCol == col;

                //check is this square is the valid move
                bool isValidMove = false;
                for (var position in validMoves) {
                  //compare row and col
                  if (position[0] == row && position[1] == col) {
                    isValidMove = true;
                  }
                }

                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  isSeleccted: isSelected,
                  isValidMove: isValidMove,
                  onTap: () => pieceSelected(row, col),
                );
              },
            ),
          ),

          //////////// Black Pieces Taken
          Expanded(
            child: GridView.builder(
              itemCount: blackPiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPieces(
                imagePath: blackPiecesTaken[index].imagePath,
                isWhite: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
