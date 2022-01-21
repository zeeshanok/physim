import 'dart:ui';

import 'package:physim/entities/ball.dart';
import 'package:physim/entities/fluids/fluid.dart';
import 'package:vector_math/vector_math.dart';

class FluidParticle extends Ball {
  double pressure;
  double density;
  Vector2 force;

  FluidParticle({required int id, required Vector2 position, Color? color})
      : pressure = 0,
        density = 0,
        force = Vector2.zero(),
        super(
          id: id,
          position: position,
          radius: fluidRadius,
          velocity: Vector2.zero(),
          acceleration: Vector2.zero(),
          color: const Color(0xFF0000FF),
        );

  @override
  void update(double dt) {
    acceleration = density == 0 ? Vector2.zero() : force / density;
    super.update(dt);
  }
}
