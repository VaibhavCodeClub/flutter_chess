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

  // Initial positions of the kings. Keeping tracks makes it easy to detect the check
  List<int> whiteKingPosition = [7, 3];
  List<int> blackKingPosition = [0, 3];
  bool checkStatus = false;

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
    //TODO
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

  void selectPiece(int row, int col) {
    setState(
      () {
        // no piece has been selected yet, this is the first selection
        if (selectedPiece == null && board[row][col] != null) {
          if (board[row][col]!.isWhite == isWhiteTurn) {
            selectedPiece = board[row][col];
            selectedRow = row;
            selectedCol = col;
          }
        }

        // There is a piece already selected, but user can select another one of their piece
        else if (board[row][col] != null &&
            board[row][col]!.isWhite == selectedPiece!.isWhite) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }

        // if there is a piece selected and user taps on a square that is a valid move, move there
        else if (selectedPiece != null &&
            validMoves
                .any((element) => element[0] == row && element[1] == col)) {
          movePiece(row, col);
        } // if the piece is selected then calculate the valid moves
        validMoves = calculateValidMoves(
          selectedRow,
          selectedCol,
          selectedPiece,
          true,
        );
      },
    );
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
        // Handle castling
        //handleCastling(row, col, piece.isWhite, board, candidateMoves);

        break;
      default:
    }
    return candidateMoves;
  }

  // Calculate valid moves
  List<List<int>> calculateValidMoves(
      int row, int col, ChessPiece? piece, bool checkSim) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    // After calculating all the moves remove the moves that will make king position dangerous
    if (checkSim) {
      for (var candidateMove in candidateMoves) {
        int endRow = candidateMove[0];
        int endCol = candidateMove[1];

        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(candidateMove);
        }
      }
    }
    return realValidMoves;
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

    // If the piece being moved is our beloved King
    if (selectedPiece!.type == ChessPieceType.king) {
      // Update the appropriate king positions such that it cannot be placed on dangerous position
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    // Move the piece and clean the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // See if Kings are being checked
    //bool isCheck = isKingInCheck(!isWhiteTurn);

    // see if any kings are under attack
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    setState(() {
      //TODO
      //checkStatus = isCheck; // Update check status
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // check if it's check mate
    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("CHECK MATE!"),
            actions: [
              TextButton(
                onPressed: resetGame,
                child: const Text("Play again"),
              )
            ],
          );
        },
      );
    }

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

          // Game Status for king check
          Text(checkStatus ? "Check!" : ""),

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
                  onTap: () => selectPiece(x, y),
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

  // Check if the king is under check or not
  bool isKingInCheck(bool isWhiteKing) {
    // Get the position of the king
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    // Iterate through all pieces on the board
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // Skip empty squares or squares with pieces of the same color
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        // Check if the piece can attack the king
        List<List<int>> pieceValidMoves =
            calculateValidMoves(i, j, board[i][j], false);

        // Check if the king is being attacked
        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }

    return false;
  }

  // Simulate valid moves which keeps king under attack are not really valid ones
  bool simulatedMoveIsSafe(
      ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    // Save the current board status
    ChessPiece? originalDestination = board[endRow][endCol];

    // If the piecec is King , save it's current position and update to new one
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;

      // Update the king position
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }
    // Simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // Check if our own king under attack or not
    bool kingInCheck = isKingInCheck(piece.isWhite);

    // Restore board to it's original state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestination;

    // If the piece was the King then restore it to original position
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }

    // If king is in the check that means it's not a valid move
    return !kingInCheck;
  }

// IS CHECK MATE?
  bool isCheckMate(bool isWhiteKing) {
    // if the king is not in check, then it's not checkmate
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    // if there is atleast one legal move for any of the player pieces, then it's not checkmate
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip the empty square and pieces of the same color as the king
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateValidMoves(i, j, board[i][j], true);
        // check if the king's position is in this peice's valid moves
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    // if none of the above condition are met, then there is not legal move left to make
    // its check mate
    return true;
  }

// RESET FOR NEW GAME4
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
}
