import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart';

abstract class Entity {
  int get id;

  void render(Canvas canvas);
  void update(double dt);
}

mixin LinearMotion on Entity {
  Vector2 position = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  Vector2 acceleration = Vector2.zero();

  void updateLinearMotion(double dt) {
    velocity += acceleration;
    position += velocity;
  }
}

mixin Collidable on Entity {
  Rect get collisionBounds;
  bool isCollidingWith(Point point);
}

mixin Bounded on LinearMotion, Collidable {
  Rect bounds = const Rect.fromLTWH(0, 0, 1000, 1000);

  void setBounds(Rect bounds) => this.bounds = bounds;

  void fixBoundsCollision() {
    final cBounds = collisionBounds.bottomCenter;
    final _bounds = bounds.bottomCenter;
    if (cBounds.dy >= _bounds.dy) {
      velocity.y *= -1;
      position.y = cBounds.dy - _bounds.dy;
    }
    if (collisionBounds.centerRight.dx >= bounds.centerRight.dx) {
      velocity.x *= -1;
      position.x = bounds.centerRight.dx - collisionBounds.centerRight.dx;
    }
  }
}

class Ball extends Entity with LinearMotion, Collidable, Bounded {
  final double radius;
  @override
  final int id;

  Ball({
    required Vector2 position,
    required this.id,
    required this.radius,
    bool hasGravity = false,
  }) {
    this.position = position;
    if (hasGravity) {
      acceleration = Vector2(0, 0.01);
    }
  }

  @override
  bool isCollidingWith(Point<num> point) {
    return false;
  }

  @override
  Rect get collisionBounds =>
      Rect.fromCircle(center: position.toOffset(), radius: radius);

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
        position.toOffset(), radius, Paint()..color = const Color(0xFFFFFFFF));
  }

  @override
  void update(double dt) {
    updateLinearMotion(dt);
    debugPrint(position.toString());
    fixBoundsCollision();
  }
}

extension ToOffset on Vector2 {
  Offset toOffset() => Offset(x, y);
}
