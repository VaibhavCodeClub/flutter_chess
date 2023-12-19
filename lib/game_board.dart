import 'dart:math';

import 'package:chess/colors.dart';
import 'package:chess/dead_pieces.dart';
import 'package:chess/helper.dart';
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

  // The currently selected piece on the board
  // If no piece is selected then set to NULL
  ChessPiece? selectedPiece;

  // The row and column index of selected piece
  // By default set to null as nothing is selected
  int selectedRow = -1;
  int selectedCol = -1;

  // List of valid moves for currently selected piece
  // Requires 2D as we are working with row and column
  List<List<int>> validMoves = [];

  // Two lists to store the pieces that have been defeated by the opponents
  List<ChessPiece> whitePiecesTaken = [];
  List<ChessPiece> blackPiecesTaken = [];

  // Boolean value to describe whose turn is it

  bool isWhiteTurn = true;

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
    newBoard[2][0] = ChessPiece(
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

  // User selects a piece

  void pieceSelected(int row, int col) {
    setState(() {
      // Select the piece is there exists unselected one
      // if (board[row][col] != null) {
      //   selectedPiece = board[row][col];
      //   selectedRow = row;
      //   selectedCol = col;
      // }

      if (selectedPiece == null && board[row][col] != null) {
        // Not even single piece is selected this is first selection
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }

      // The piece is already selected but now user wants to select another one then
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }

      // If user selects the piece and clicks on the valid move square, then move the piece there
      else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      // If piece is selected, calculate it's valid moves
      validMoves =
          calculateRawValidMoves(selectedRow, selectedCol, selectedPiece);
    });
  }

  // Calculate raw valid moves
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }

    // Different directions based on their colors
    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        // Pawn moves forward a square
        if (isWithinBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        // Pawn moves forward 2 squares at start position
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isWithinBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        // Pawn attacks  opponent diagonally

        if (piece.isWhite) {
          if (isWithinBoard(row + direction, col - 1) &&
              board[row + direction][col - 1] != null &&
              !board[row + direction][col - 1]!.isWhite) {
            candidateMoves.add([row + direction, col - 1]);
          }
          if (isWithinBoard(row + direction, col + 1) &&
              board[row + direction][col + 1] != null &&
              !board[row + direction][col + 1]!.isWhite) {
            candidateMoves.add([row + direction, col + 1]);
          }
        } else {
          if (isWithinBoard(row + direction, col - 1) &&
              board[row + direction][col - 1] != null &&
              board[row + direction][col - 1]!.isWhite) {
            candidateMoves.add([row + direction, col - 1]);
          }
          if (isWithinBoard(row + direction, col + 1) &&
              board[row + direction][col + 1] != null &&
              board[row + direction][col + 1]!.isWhite) {
            candidateMoves.add([row + direction, col + 1]);
          }
        }

        break;
      case ChessPieceType.bishop:
        // Bihop moves diagonally
        var directions = [
          [-1, -1], // up-left
          [-1, 1], // up-right
          [1, -1], // down-left
          [1, 1], // down-right
        ];

        for (var dirIndex = 0; dirIndex < directions.length; dirIndex++) {
          var direction = directions[dirIndex];
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isWithinBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // attacks
              }
              break; // Block
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.knight:
        // All possible eight 2.5/L shapes the knight can move
        var knightMoves = [
          [-2, -1],
          [-2, 1],
          [-1, -2],
          [-1, 2],
          [1, -2],
          [1, 2],
          [2, -1],
          [2, 1],
        ];
        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isWithinBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // attacks
            }
            continue; // Block
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;
      case ChessPieceType.rook:
        // Directions as rook moves in vertical and horizontal
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
        ];

        for (var dirIndex = 0; dirIndex < directions.length; dirIndex++) {
          var direction = directions[dirIndex];
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isWithinBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // attacks
              }
              break; // Block
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.queen:
        var directionsQueen = [
          [-1, -1], // up-left
          [-1, 0], // up
          [-1, 1], // up-right
          [0, -1], // left
          [0, 1], // right
          [1, -1], // down-left
          [1, 0], // down
          [1, 1], // down-right
        ];

        for (var dirIndex = 0; dirIndex < directionsQueen.length; dirIndex++) {
          var direction = directionsQueen[dirIndex];
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isWithinBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // attacks
              }
              break; // Block
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.king:
        var directionsKing = [
          [-1, -1], // up-left
          [-1, 0], // up
          [-1, 1], // up-right
          [0, -1], // left
          [0, 1], // right
          [1, -1], // down-left
          [1, 0], // down
          [1, 1], // down-right
        ];

        for (var dirIndex = 0; dirIndex < directionsKing.length; dirIndex++) {
          var direction = directionsKing[dirIndex];
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (isWithinBoard(newRow, newCol) &&
              (board[newRow][newCol] == null ||
                  board[newRow][newCol]!.isWhite != piece.isWhite)) {
            candidateMoves.add([newRow, newCol]); // valid move
          }
        }

        break;
      default:
    }
    return candidateMoves;
  }

  // Move piece

  void movePiece(int newRow, int newCol) {
    // If the new spot has the enemy piece add it to captured list
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      capturedPiece!.isWhite
          ? whitePiecesTaken.add(capturedPiece)
          : blackPiecesTaken.add(capturedPiece);
    }

    // Move the piece and clean the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // clear the selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // Change the turns
    isWhiteTurn = !isWhiteTurn;
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
      body: Column(
        children: [
          // White pieces taken
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: whitePiecesTaken.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
            ),
          ),

          // ChessBoard
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder: (context, index) {
                // Get row and col of that board
                int x = index ~/ 8;
                int y = index % 8;

                // Check if the square is selected or not
                bool isSelected = selectedRow == x && selectedCol == y;

                // Check if the square is valid move or not
                bool isValidMove = false;
                for (var element in validMoves) {
                  // Compare rows and cols
                  if (element[0] == x && element[1] == y) {
                    isValidMove = true;
                  }
                }

                return Square(
                  isWhite: isWhite(index),
                  piece: board[x][y],
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  onTap: () => pieceSelected(x, y),
                );
              },
            ),
          ),

          // Black pieces taken
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: blackPiecesTaken.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
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
