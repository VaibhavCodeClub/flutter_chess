import 'package:chess/colors.dart';
import 'package:chess/is_white.dart';
import 'package:chess/piece.dart';
import 'package:chess/square.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // 2D list representing chessboard
  // With each position possibly containing a chess piece
  late List<List<ChessPiece?>> board;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  // Initialize board
  void _initializeBoard() {
    // Initiaizing board with null values, meaning no piece at that position......
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    // Place pawns

    for (var i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: "images/pawn.png");

      newBoard[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: "images/pawn.png");
    }

    // Place knights
    newBoard[0][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: "images/knight.png",
    );
    newBoard[0][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: "images/knight.png",
    );
    newBoard[7][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: "images/knight.png",
    );
    newBoard[7][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: "images/knight.png",
    );

    // Place bishops
    newBoard[0][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: "images/bishop.png",
    );
    newBoard[0][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: "images/bishop.png",
    );
    newBoard[7][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: "images/bishop.png",
    );
    newBoard[7][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: "images/bishop.png",
    );

    // Place rooks
    newBoard[0][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: "images/rook.png",
    );
    newBoard[0][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: "images/rook.png",
    );
    newBoard[7][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: "images/rook.png",
    );
    newBoard[7][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: "images/rook.png",
    );

    // Place queens
    newBoard[0][4] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: false,
      imagePath: "images/queen.png",
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: true,
      imagePath: "images/queen.png",
    );

    // Place kings
    newBoard[0][3] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: false,
      imagePath: "images/king.png",
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: true,
      imagePath: "images/king.png",
    );

    board = newBoard;
  }

  // pawn
  // ChessPiece whitePawn = ChessPiece(
  //   type: ChessPieceType.pawn,
  //   isWhite: true,
  //   imagePath: 'images/pawn.png',
  // );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: GridView.builder(
        itemCount: 8 * 8,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemBuilder: (context, index) {
          // Get row and col of that board
          int x = index ~/ 8;
          int y = index % 8;

          return Square(
            isWhite: isWhite(index),
            piece: board[x][y],
          );
        },
      ),
    );
  }
}
