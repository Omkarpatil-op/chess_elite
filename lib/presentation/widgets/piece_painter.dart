import 'package:flutter/material.dart';
import '../../core/chess_engine/models/piece.dart';
import '../../core/theme/piece_themes.dart';

class ChessPieceWidget extends StatelessWidget {
  final Piece piece;
  final double size;
  final PieceStyle style;

  const ChessPieceWidget({
    super.key,
    required this.piece,
    this.size = 48,
    this.style = PieceStyle.stauntonClassic,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: PiecePainter(piece: piece, style: style),
      ),
    );
  }
}

class PiecePainter extends CustomPainter {
  final Piece piece;
  final PieceStyle style;

  PiecePainter({required this.piece, required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    final isWhite = piece.isWhite;
    final w = size.width;
    final h = size.height;

    // Palette
    final fillColor = isWhite ? const Color(0xFFFFFFFF) : const Color(0xFF1F2328);
    final strokeColor = isWhite ? const Color(0xFF24292F) : const Color(0xFFE6EDF3);
    final highlightColor = isWhite ? const Color(0xFFF0F6FC) : const Color(0xFF30363D);

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final detailStroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;

    final highlightPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill;

    switch (piece.type) {
      case PieceType.pawn:
        _drawPawn(canvas, w, h, fillPaint, strokePaint, detailStroke, highlightPaint);
        break;
      case PieceType.knight:
        _drawKnight(canvas, w, h, fillPaint, strokePaint, detailStroke, isWhite);
        break;
      case PieceType.bishop:
        _drawBishop(canvas, w, h, fillPaint, strokePaint, detailStroke, highlightPaint);
        break;
      case PieceType.rook:
        _drawRook(canvas, w, h, fillPaint, strokePaint, detailStroke);
        break;
      case PieceType.queen:
        _drawQueen(canvas, w, h, fillPaint, strokePaint, detailStroke);
        break;
      case PieceType.king:
        _drawKing(canvas, w, h, fillPaint, strokePaint, detailStroke);
        break;
    }
  }

  void _drawPawn(
    Canvas canvas,
    double w,
    double h,
    Paint fill,
    Paint stroke,
    Paint detail,
    Paint highlight,
  ) {
    // 1. Head circle
    final headCenter = Offset(w * 0.5, h * 0.32);
    final headRadius = w * 0.16;
    canvas.drawCircle(headCenter, headRadius, fill);
    canvas.drawCircle(headCenter, headRadius, stroke);

    // 2. Collar & Body
    final path = Path();
    path.moveTo(w * 0.36, h * 0.44);
    path.quadraticBezierTo(w * 0.5, h * 0.42, w * 0.64, h * 0.44);
    path.quadraticBezierTo(w * 0.56, h * 0.65, w * 0.70, h * 0.76);
    path.lineTo(w * 0.30, h * 0.76);
    path.quadraticBezierTo(w * 0.44, h * 0.65, w * 0.36, h * 0.44);
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // 3. Base
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.82), width: w * 0.54, height: h * 0.12),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(baseRect, fill);
    canvas.drawRRect(baseRect, stroke);
  }

  void _drawKnight(
    Canvas canvas,
    double w,
    double h,
    Paint fill,
    Paint stroke,
    Paint detail,
    bool isWhite,
  ) {
    final path = Path();
    // Staunton Horse Head Profile
    path.moveTo(w * 0.28, h * 0.82); // Base left
    path.lineTo(w * 0.72, h * 0.82); // Base right
    path.quadraticBezierTo(w * 0.68, h * 0.60, w * 0.62, h * 0.40); // Mane
    path.lineTo(w * 0.64, h * 0.22); // Ear top
    path.lineTo(w * 0.54, h * 0.28); // Forehead
    path.quadraticBezierTo(w * 0.42, h * 0.32, w * 0.28, h * 0.45); // Snout top
    path.lineTo(w * 0.26, h * 0.54); // Nostril
    path.quadraticBezierTo(w * 0.36, h * 0.56, w * 0.42, h * 0.52); // Mouth
    path.quadraticBezierTo(w * 0.46, h * 0.62, w * 0.38, h * 0.74); // Chest
    path.lineTo(w * 0.28, h * 0.82);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Eye
    final eyeCenter = Offset(w * 0.46, h * 0.38);
    canvas.drawCircle(eyeCenter, w * 0.04, stroke);

    // Mane details
    canvas.drawLine(Offset(w * 0.58, h * 0.35), Offset(w * 0.66, h * 0.42), detail);
    canvas.drawLine(Offset(w * 0.56, h * 0.48), Offset(w * 0.65, h * 0.55), detail);
  }

  void _drawBishop(
    Canvas canvas,
    double w,
    double h,
    Paint fill,
    Paint stroke,
    Paint detail,
    Paint highlight,
  ) {
    // Top cross/orb
    canvas.drawCircle(Offset(w * 0.5, h * 0.16), w * 0.04, fill);
    canvas.drawCircle(Offset(w * 0.5, h * 0.16), w * 0.04, stroke);

    // Mitre Body
    final path = Path();
    path.moveTo(w * 0.5, h * 0.20);
    path.quadraticBezierTo(w * 0.74, h * 0.34, w * 0.66, h * 0.60);
    path.quadraticBezierTo(w * 0.68, h * 0.72, w * 0.70, h * 0.76);
    path.lineTo(w * 0.30, h * 0.76);
    path.quadraticBezierTo(w * 0.32, h * 0.72, w * 0.34, h * 0.60);
    path.quadraticBezierTo(w * 0.26, h * 0.34, w * 0.5, h * 0.20);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Bishop cut / slash
    canvas.drawLine(Offset(w * 0.44, h * 0.28), Offset(w * 0.58, h * 0.44), detail);

    // Collar & Base
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.82), width: w * 0.56, height: h * 0.12),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(baseRect, fill);
    canvas.drawRRect(baseRect, stroke);
  }

  void _drawRook(
    Canvas canvas,
    double w,
    double h,
    Paint fill,
    Paint stroke,
    Paint detail,
  ) {
    final path = Path();
    // Crenellations (Castle turrets)
    path.moveTo(w * 0.26, h * 0.24);
    path.lineTo(w * 0.34, h * 0.24);
    path.lineTo(w * 0.34, h * 0.32);
    path.lineTo(w * 0.44, h * 0.32);
    path.lineTo(w * 0.44, h * 0.24);
    path.lineTo(w * 0.56, h * 0.24);
    path.lineTo(w * 0.56, h * 0.32);
    path.lineTo(w * 0.66, h * 0.32);
    path.lineTo(w * 0.66, h * 0.24);
    path.lineTo(w * 0.74, h * 0.24);
    path.lineTo(w * 0.70, h * 0.40);
    path.lineTo(w * 0.64, h * 0.74);
    path.lineTo(w * 0.36, h * 0.74);
    path.lineTo(w * 0.30, h * 0.40);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Castle waist line
    canvas.drawLine(Offset(w * 0.30, h * 0.40), Offset(w * 0.70, h * 0.40), detail);

    // Base
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.82), width: w * 0.58, height: h * 0.13),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(baseRect, fill);
    canvas.drawRRect(baseRect, stroke);
  }

  void _drawQueen(
    Canvas canvas,
    double w,
    double h,
    Paint fill,
    Paint stroke,
    Paint detail,
  ) {
    // Crown Jewels (5 orbs)
    final orbs = [
      Offset(w * 0.22, h * 0.22),
      Offset(w * 0.36, h * 0.17),
      Offset(w * 0.50, h * 0.14),
      Offset(w * 0.64, h * 0.17),
      Offset(w * 0.78, h * 0.22),
    ];
    for (final orb in orbs) {
      canvas.drawCircle(orb, w * 0.035, fill);
      canvas.drawCircle(orb, w * 0.035, stroke);
    }

    // Crown spikes & body
    final path = Path();
    path.moveTo(w * 0.22, h * 0.24);
    path.lineTo(w * 0.30, h * 0.42);
    path.lineTo(w * 0.36, h * 0.20);
    path.lineTo(w * 0.44, h * 0.42);
    path.lineTo(w * 0.50, h * 0.17);
    path.lineTo(w * 0.56, h * 0.42);
    path.lineTo(w * 0.64, h * 0.20);
    path.lineTo(w * 0.70, h * 0.42);
    path.lineTo(w * 0.78, h * 0.24);
    path.quadraticBezierTo(w * 0.74, h * 0.60, w * 0.68, h * 0.74);
    path.lineTo(w * 0.32, h * 0.74);
    path.quadraticBezierTo(w * 0.26, h * 0.60, w * 0.22, h * 0.24);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Waist band
    canvas.drawLine(Offset(w * 0.31, h * 0.48), Offset(w * 0.69, h * 0.48), detail);

    // Base
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.82), width: w * 0.62, height: h * 0.13),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(baseRect, fill);
    canvas.drawRRect(baseRect, stroke);
  }

  void _drawKing(
    Canvas canvas,
    double w,
    double h,
    Paint fill,
    Paint stroke,
    Paint detail,
  ) {
    // Cross on top
    final crossV = Path()
      ..moveTo(w * 0.50, h * 0.10)
      ..lineTo(w * 0.50, h * 0.24);
    final crossH = Path()
      ..moveTo(w * 0.42, h * 0.16)
      ..lineTo(w * 0.58, h * 0.16);

    canvas.drawPath(crossV, stroke);
    canvas.drawPath(crossH, stroke);

    // Crown Body
    final path = Path();
    path.moveTo(w * 0.32, h * 0.26);
    path.quadraticBezierTo(w * 0.50, h * 0.20, w * 0.68, h * 0.26);
    path.quadraticBezierTo(w * 0.78, h * 0.36, w * 0.72, h * 0.52);
    path.quadraticBezierTo(w * 0.68, h * 0.65, w * 0.68, h * 0.74);
    path.lineTo(w * 0.32, h * 0.74);
    path.quadraticBezierTo(w * 0.32, h * 0.65, w * 0.28, h * 0.52);
    path.quadraticBezierTo(w * 0.22, h * 0.36, w * 0.32, h * 0.26);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Arches in royal crown
    canvas.drawLine(Offset(w * 0.34, h * 0.44), Offset(w * 0.66, h * 0.44), detail);
    canvas.drawLine(Offset(w * 0.50, h * 0.24), Offset(w * 0.50, h * 0.44), detail);

    // Base
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.82), width: w * 0.64, height: h * 0.13),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(baseRect, fill);
    canvas.drawRRect(baseRect, stroke);
  }

  @override
  bool shouldRepaint(covariant PiecePainter oldDelegate) =>
      oldDelegate.piece != piece || oldDelegate.style != style;
}
