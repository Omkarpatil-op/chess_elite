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

    // Premium Color Palette
    Color baseFill;
    Color strokeColor;
    Color highlightColor;
    Color detailColor;

    if (style == PieceStyle.woodCarved) {
      baseFill = isWhite ? const Color(0xFFF3E5AB) : const Color(0xFF5C3A21);
      strokeColor = isWhite ? const Color(0xFF5D4037) : const Color(0xFF2C1609);
      highlightColor = isWhite ? const Color(0xFFFFF8E7) : const Color(0xFF8D5B36);
      detailColor = isWhite ? const Color(0xFF8D6E63) : const Color(0xFFD7CCC8);
    } else if (style == PieceStyle.neoModern) {
      baseFill = isWhite ? const Color(0xFFFFFFFF) : const Color(0xFF1E293B);
      strokeColor = isWhite ? const Color(0xFF0F172A) : const Color(0xFF94A3B8);
      highlightColor = isWhite ? const Color(0xFFF1F5F9) : const Color(0xFF334155);
      detailColor = strokeColor;
    } else if (style == PieceStyle.minimalAlpha) {
      baseFill = isWhite ? const Color(0xFFFFFFFF) : const Color(0xFF18181B);
      strokeColor = isWhite ? const Color(0xFF18181B) : const Color(0xFFE4E4E7);
      highlightColor = isWhite ? const Color(0xFFFAFAFA) : const Color(0xFF27272A);
      detailColor = strokeColor;
    } else {
      // Staunton Classic Tournament Standard
      baseFill = isWhite ? const Color(0xFFFFFFFF) : const Color(0xFF1A1E24);
      strokeColor = isWhite ? const Color(0xFF2B313A) : const Color(0xFFE2E8F0);
      highlightColor = isWhite ? const Color(0xFFF8FAFC) : const Color(0xFF333B47);
      detailColor = isWhite ? const Color(0xFF374151) : const Color(0xFFCBD5E1);
    }

    final fillPaint = Paint()
      ..color = baseFill
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w * 0.046).clamp(1.5, 3.5)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final detailStroke = Paint()
      ..color = detailColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w * 0.034).clamp(1.0, 2.5)
      ..strokeCap = StrokeCap.round;

    final highlightPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill;

    // Subtle drop shadow under piece base for 3D depth
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.88), width: w * 0.65, height: h * 0.10),
      shadowPaint,
    );

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
    // 1. Head circle with highlight
    final headCenter = Offset(w * 0.5, h * 0.30);
    final headRadius = w * 0.16;
    canvas.drawCircle(headCenter, headRadius, fill);
    canvas.drawCircle(headCenter, headRadius, stroke);

    // 2. Collar & Curving Body
    final path = Path();
    path.moveTo(w * 0.36, h * 0.43);
    path.quadraticBezierTo(w * 0.5, h * 0.40, w * 0.64, h * 0.43);
    path.quadraticBezierTo(w * 0.55, h * 0.62, w * 0.68, h * 0.76);
    path.lineTo(w * 0.32, h * 0.76);
    path.quadraticBezierTo(w * 0.45, h * 0.62, w * 0.36, h * 0.43);
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // 3. Tiered Base
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.82), width: w * 0.56, height: h * 0.11),
      Radius.circular(w * 0.04),
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
    // Staunton Championship Horse Head Silhouette
    path.moveTo(w * 0.26, h * 0.82);
    path.lineTo(w * 0.74, h * 0.82);
    path.quadraticBezierTo(w * 0.70, h * 0.58, w * 0.64, h * 0.38); // Arched neck
    path.lineTo(w * 0.66, h * 0.20); // Ear tip
    path.lineTo(w * 0.55, h * 0.26); // Forehead
    path.quadraticBezierTo(w * 0.42, h * 0.30, w * 0.26, h * 0.44); // Muzzle slope
    path.lineTo(w * 0.24, h * 0.53); // Snout
    path.quadraticBezierTo(w * 0.35, h * 0.55, w * 0.42, h * 0.50); // Lower jaw
    path.quadraticBezierTo(w * 0.46, h * 0.60, w * 0.36, h * 0.73); // Chest
    path.lineTo(w * 0.26, h * 0.82);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Eye orb
    final eyeCenter = Offset(w * 0.46, h * 0.36);
    canvas.drawCircle(eyeCenter, w * 0.04, stroke);

    // Mane arcs
    canvas.drawLine(Offset(w * 0.59, h * 0.32), Offset(w * 0.68, h * 0.40), detail);
    canvas.drawLine(Offset(w * 0.57, h * 0.45), Offset(w * 0.67, h * 0.53), detail);
    canvas.drawLine(Offset(w * 0.55, h * 0.58), Offset(w * 0.66, h * 0.66), detail);

    // Nostril mark
    canvas.drawCircle(Offset(w * 0.30, h * 0.49), w * 0.02, detail);
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
    // Cross / Top Orb
    canvas.drawCircle(Offset(w * 0.5, h * 0.14), w * 0.045, fill);
    canvas.drawCircle(Offset(w * 0.5, h * 0.14), w * 0.045, stroke);

    // Mitre Body
    final path = Path();
    path.moveTo(w * 0.5, h * 0.18);
    path.quadraticBezierTo(w * 0.75, h * 0.32, w * 0.67, h * 0.58);
    path.quadraticBezierTo(w * 0.68, h * 0.70, w * 0.70, h * 0.76);
    path.lineTo(w * 0.30, h * 0.76);
    path.quadraticBezierTo(w * 0.32, h * 0.70, w * 0.33, h * 0.58);
    path.quadraticBezierTo(w * 0.25, h * 0.32, w * 0.5, h * 0.18);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Bishop cut / iconic mitre slash
    canvas.drawLine(Offset(w * 0.42, h * 0.27), Offset(w * 0.58, h * 0.43), detail);

    // Base collar
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.82), width: w * 0.58, height: h * 0.11),
      Radius.circular(w * 0.04),
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
    // Battlements / Crenellated Fortress Turrets
    path.moveTo(w * 0.25, h * 0.22);
    path.lineTo(w * 0.34, h * 0.22);
    path.lineTo(w * 0.34, h * 0.31);
    path.lineTo(w * 0.44, h * 0.31);
    path.lineTo(w * 0.44, h * 0.22);
    path.lineTo(w * 0.56, h * 0.22);
    path.lineTo(w * 0.56, h * 0.31);
    path.lineTo(w * 0.66, h * 0.31);
    path.lineTo(w * 0.66, h * 0.22);
    path.lineTo(w * 0.75, h * 0.22);
    path.lineTo(w * 0.71, h * 0.39);
    path.lineTo(w * 0.65, h * 0.74);
    path.lineTo(w * 0.35, h * 0.74);
    path.lineTo(w * 0.29, h * 0.39);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Waist Line
    canvas.drawLine(Offset(w * 0.29, h * 0.39), Offset(w * 0.71, h * 0.39), detail);

    // Castle Base
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.82), width: w * 0.60, height: h * 0.12),
      Radius.circular(w * 0.04),
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
    // 5 Royal Crown Orbs
    final orbs = [
      Offset(w * 0.20, h * 0.20),
      Offset(w * 0.35, h * 0.15),
      Offset(w * 0.50, h * 0.12),
      Offset(w * 0.65, h * 0.15),
      Offset(w * 0.80, h * 0.20),
    ];
    for (final orb in orbs) {
      canvas.drawCircle(orb, w * 0.038, fill);
      canvas.drawCircle(orb, w * 0.038, stroke);
    }

    // Majestic Crown Body
    final path = Path();
    path.moveTo(w * 0.20, h * 0.23);
    path.lineTo(w * 0.29, h * 0.40);
    path.lineTo(w * 0.35, h * 0.18);
    path.lineTo(w * 0.43, h * 0.40);
    path.lineTo(w * 0.50, h * 0.15);
    path.lineTo(w * 0.57, h * 0.40);
    path.lineTo(w * 0.65, h * 0.18);
    path.lineTo(w * 0.71, h * 0.40);
    path.lineTo(w * 0.80, h * 0.23);
    path.quadraticBezierTo(w * 0.75, h * 0.58, w * 0.69, h * 0.74);
    path.lineTo(w * 0.31, h * 0.74);
    path.quadraticBezierTo(w * 0.25, h * 0.58, w * 0.20, h * 0.23);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Crown Waist Band
    canvas.drawLine(Offset(w * 0.29, h * 0.46), Offset(w * 0.71, h * 0.46), detail);

    // Royal Base
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.82), width: w * 0.64, height: h * 0.12),
      Radius.circular(w * 0.04),
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
    // Sovereign Cross on Crown Peak
    final crossV = Path()
      ..moveTo(w * 0.50, h * 0.08)
      ..lineTo(w * 0.50, h * 0.22);
    final crossH = Path()
      ..moveTo(w * 0.41, h * 0.14)
      ..lineTo(w * 0.59, h * 0.14);

    canvas.drawPath(crossV, stroke);
    canvas.drawPath(crossH, stroke);

    // Sovereign Crown Profile
    final path = Path();
    path.moveTo(w * 0.30, h * 0.24);
    path.quadraticBezierTo(w * 0.50, h * 0.18, w * 0.70, h * 0.24);
    path.quadraticBezierTo(w * 0.80, h * 0.35, w * 0.73, h * 0.52);
    path.quadraticBezierTo(w * 0.70, h * 0.65, w * 0.69, h * 0.74);
    path.lineTo(w * 0.31, h * 0.74);
    path.quadraticBezierTo(w * 0.30, h * 0.65, w * 0.27, h * 0.52);
    path.quadraticBezierTo(w * 0.20, h * 0.35, w * 0.30, h * 0.24);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Imperial Arch lines
    canvas.drawLine(Offset(w * 0.33, h * 0.42), Offset(w * 0.67, h * 0.42), detail);
    canvas.drawLine(Offset(w * 0.50, h * 0.22), Offset(w * 0.50, h * 0.42), detail);

    // Grandmaster Base
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.82), width: w * 0.66, height: h * 0.12),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(baseRect, fill);
    canvas.drawRRect(baseRect, stroke);
  }

  @override
  bool shouldRepaint(covariant PiecePainter oldDelegate) =>
      oldDelegate.piece != piece || oldDelegate.style != style;
}
