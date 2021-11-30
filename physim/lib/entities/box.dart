import 'dart:math';
import 'dart:ui';

import 'package:physim/entities/entity.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

class Box extends Entity with LinearMotion, Collidable, MotionBoundary {
  final double width;
  final double height;
  final Color color;
  @override
  final int id;

  Box(
      {required this.id,
      required this.width,
      required this.height,
      required this.color,
      Vector2? position,
      Vector2? velocity,
      Vector2? acceleration}) {
    this.position = position ?? Vector2.zero();
    this.velocity = velocity ?? Vector2.zero();
    this.acceleration = acceleration ?? Vector2.zero();
  }

  @override
  bool isCollidingWith(Point point) => false;

  Rect get asRect => Rect.fromLTWH(
      position.x - width / 2, position.y - height / 2, width, height);

  @override
  Rect get collisionBounds => asRect;

  @override
  double getValidMaxX(double maxX) => maxX - (width / 2);
  @override
  double getValidMaxY(double maxY) => maxY - (height / 2);
  @override
  double getValidMinX(double minX) => width;
  @override
  double getValidMinY(double minY) => height;

  @override
  void update(double dt) {
    updateLinearMotion(dt);
    fixBoundsCollision();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
        asRect,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }
}
