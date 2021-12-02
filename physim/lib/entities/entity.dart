import 'dart:math';
import 'dart:ui';

import 'package:physim/entities/ball.dart';
import 'package:physim/entities/box.dart';
import 'package:vector_math/vector_math.dart';

export 'mixins/collidable.dart';
export 'mixins/linear_motion.dart';
export 'mixins/motion_boundary.dart';

abstract class Entity {
  int get id;

  void render(Canvas canvas);
  void update(double dt);
}

extension ToOffset on Vector2 {
  Offset toOffset() => Offset(x, y);
}

extension ToVector2 on Offset {
  Vector2 toVector2() => Vector2(dx, dy);
}

extension RoundTo on double {
  double roundTo(int decimals) {
    final p = pow(100, decimals);
    return (this * p).round() / p;
  }
}

Map<String, Type>? toTypeMap(Type type) {
  switch (type) {
    case Ball:
      return {
        "Radius": double,
        "Position": Vector2,
        "Velocity": Vector2,
        "Acceleration": Vector2,
        "Color": Color,
        "Filled": bool
      };
    case Box:
      return {
        "Width": double,
        "Height": double,
        "Position": Vector2,
        "Velocity": Vector2,
        "Acceleration": Vector2,
        "Color": Color,
        "Filled": bool
      };
  }
}

void renderGhost(Canvas canvas, Type type, Vector2 position) {
  const color = Color(0xAA909090);
  switch (type) {
    case Ball:
      return Ball(
        id: -1,
        position: position,
        radius: 18,
        color: color,
      ).render(canvas);

    case Box:
      return Box(
        id: -1,
        height: 30,
        width: 30,
        position: position,
        color: color,
      ).render(canvas);
  }
}
