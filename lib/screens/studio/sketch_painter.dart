import 'package:flutter/material.dart';

import '../../models/sketch.dart';
import '../../utils/formats.dart';

class SketchPainter extends CustomPainter {
  const SketchPainter({
    required this.shapes,
    required this.showGrid,
    required this.pixelsPerMeter,
    this.changes = 0,
    this.selectedIndex,
    this.drawStart,
    this.livePoint,
    this.measureStart,
  });

  final List<SketchShape> shapes;
  final bool showGrid;
  final double pixelsPerMeter;
  final int changes;
  final int? selectedIndex;
  final Offset? drawStart;
  final Offset? livePoint;
  final Offset? measureStart;

  static const wallColor = Color(0xFF1F2937);
  static const roomFill = Color(0x1A0F766E);
  static const roomStroke = Color(0xFF0F766E);
  static const accent = Color(0xFF0891B2);
  static const measureColor = Color(0xFFDC2626);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.white,
    );

    if (showGrid) {
      _drawGrid(canvas, size);
    }

    for (var i = 0; i < shapes.length; i++) {
      _drawShape(canvas, shapes[i], i == selectedIndex);
    }

    _drawPreview(canvas);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final light = Paint()
      ..color = const Color(0xFFECEEF0)
      ..strokeWidth = 1;
    final strong = Paint()
      ..color = const Color(0xFFD8DCDF)
      ..strokeWidth = 1;

    double x = 0;
    var i = 0;
    while (x <= size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), i % 5 == 0 ? strong : light);
      x += pixelsPerMeter;
      i++;
    }
    double y = 0;
    i = 0;
    while (y <= size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), i % 5 == 0 ? strong : light);
      y += pixelsPerMeter;
      i++;
    }
  }

  void _drawShape(Canvas canvas, SketchShape s, bool selected) {
    switch (s.type) {
      case 'wall':
        final paint = Paint()
          ..color = selected ? accent : wallColor
          ..strokeWidth = s.thickness
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(s.a, s.b, paint);
        _label(canvas, formatLength(s.length / pixelsPerMeter), s.midPoint);
        break;
      case 'room':
        final rect = Rect.fromPoints(s.a, s.b);
        canvas.drawRect(
          rect,
          Paint()..color = selected ? const Color(0x33F59E0B) : roomFill,
        );
        canvas.drawRect(
          rect,
          Paint()
            ..color = selected ? accent : roomStroke
            ..strokeWidth = 4
            ..style = PaintingStyle.stroke,
        );
        final w = (rect.width / pixelsPerMeter).toStringAsFixed(1);
        final h = (rect.height / pixelsPerMeter).toStringAsFixed(1);
        _label(canvas, '$w × $h م', s.midPoint);
        break;
      case 'measure':
        final paint = Paint()
          ..color = measureColor
          ..strokeWidth = 2;
        canvas.drawLine(s.a, s.b, paint);
        canvas.drawCircle(s.a, 4, paint);
        canvas.drawCircle(s.b, 4, paint);
        _label(canvas, formatLength(s.length / pixelsPerMeter), s.midPoint);
        break;
    }
  }

  void _drawPreview(Canvas canvas) {
    if (measureStart != null) {
      canvas.drawCircle(
        measureStart!,
        5,
        Paint()
          ..color = measureColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _label(canvas, 'النقطة الأولى', measureStart! + const Offset(8, -8));
    }

    if (drawStart == null || livePoint == null) return;
    final start = drawStart!;
    final end = livePoint!;
    final paint = Paint()
      ..color = const Color(0xFF0891B2)
      ..strokeWidth = 1.2;
    final dash = 6.0;
    final gap = 4.0;
    var t = 0.0;
    final total = (end - start).distance;
    while (t < total) {
      final p1 = start + (end - start) * (t / total);
      final p2 = start + (end - start) * ((t + dash) / total).clamp(0, 1);
      canvas.drawLine(p1, p2, paint);
      t += dash + gap;
    }
  }

  void _label(Canvas canvas, String text, Offset pos) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1B2B31),
        ),
        // A small contrast backing improves readability.
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    final rect = Rect.fromCenter(
      center: pos,
      width: tp.width + 8,
      height: tp.height + 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant SketchPainter oldDelegate) {
    return oldDelegate.changes != changes ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.pixelsPerMeter != pixelsPerMeter ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.drawStart != drawStart ||
        oldDelegate.livePoint != livePoint ||
        oldDelegate.measureStart != measureStart;
  }
}
