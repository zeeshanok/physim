import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:physim/entities/entity.dart';
import 'package:vector_math/vector_math.dart';

class Ball extends Entity with LinearMotion, Collidable, MotionBoundary {
  @override
  final int id;
  final double radius;
  final Color color;

  Ball({
    required Vector2 position,
    Vector2? velocity,
    Vector2? acceleration,
    Color? color,
    required this.id,
    required this.radius,
  }) : color = color ?? const Color(0xFFFFFFFF) {
    this.position = position;
    this.velocity = velocity ?? Vector2.zero();
    this.acceleration = acceleration ?? Vector2.zero();
  }

  @override
  bool isCollidingWith(Point point) {
    return false;
  }

  @override
  Rect get collisionBounds =>
      Rect.fromCircle(center: position.toOffset(), radius: radius);

  @override
  double getValidMaxX(double maxX) => maxX - radius;
  @override
  double getValidMinX(double minX) => minX + radius;
  @override
  double getValidMaxY(double maxY) => maxY - radius;
  @override
  double getValidMinY(double minY) => minY + radius;

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
        position.toOffset(),
        radius,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // final angle = velocity.angleToSigned(Vector2(0, 1));
    // final head = Vector2(
    //     radius * sin(angle) * (velocity.length + 0.75) + position.x,
    //     radius * cos(angle) * (velocity.length + 0.75) + position.y);
    // final headAngle = -head.angleTo(Vector2(0, 1));
    // final path = Path()
    //   ..moveTo(position.x, position.y)
    //   ..lineTo(head.x, head.y);
    // ..lineTo(head.x + 10 * cos(pi / 4 + headAngle),
    //     head.y + 10 * sin(pi / 4 + headAngle))
    // ..moveTo(head.x, head.y)
    // ..lineTo(head.x - 10 * cos(pi / 4 + headAngle),
    //     head.y - 10 * sin(pi / 4 - headAngle));
    // canvas.drawPath(
    //     path,
    //     Paint()
    //       ..style = PaintingStyle.stroke
    //       ..color = const Color(0x44AAAAAA)
    //       ..strokeWidth = 2);
    // final p = TextPainter(
    //     text: TextSpan(
    //         text: "${velocity.x.roundTo(1)}, ${velocity.y.roundTo(1)}"),
    //     textDirection: TextDirection.ltr);
    // p.layout();
    // p.paint(canvas, position.toOffset() - Offset(-10 - radius, 10 + radius));
  }

  @override
  void update(double dt) {
    updateLinearMotion(dt);
    fixBoundsCollision();
  }
}
