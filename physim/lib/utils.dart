import 'dart:math';

import 'package:flutter/painting.dart';

final decimalRegExp = RegExp(r'^-?\d*([.,]?\d*)?$');

extension DrawArrow on Canvas {
  void drawArrow({
    required Offset start,
    required Offset end,
    required double headAngle,
    double strokeWidth = 1,
  }) {
    final a = atan2((end - start).dy, (end - start).dx);
    final a1 = a + headAngle + pi / 2;
    final a2 = a - headAngle - pi / 2;

    final p1 = Offset(end.dx + 10 * cos(a1), end.dy + 10 * sin(a1));
    final p2 = Offset(end.dx + 10 * cos(a2), end.dy + 10 * sin(a2));

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy)
      ..lineTo(p1.dx, p1.dy)
      ..moveTo(end.dx, end.dy)
      ..lineTo(p2.dx, p2.dy);

    drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.bevel,
    );
  }
}
