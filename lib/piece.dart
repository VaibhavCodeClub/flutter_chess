enum ChessPieceType { pawn, knight, bishop, rook, queen, king }

class ChessPiece {
  final ChessPieceType type;
  final bool isWhite;
  final String imagePath;
  bool hasMoved;

  ChessPiece({
    required this.type,
    required this.isWhite,
    required this.hasMoved,
    required this.imagePath,
  });
}
