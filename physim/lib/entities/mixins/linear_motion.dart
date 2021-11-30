import 'package:physim/entities/entity.dart';
import 'package:vector_math/vector_math.dart';

mixin LinearMotion on Entity {
  Vector2 position = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  Vector2 acceleration = Vector2.zero();

  void updateLinearMotion(double dt) {
    velocity += acceleration;
    if (acceleration.x == 0 && velocity.x.abs() < 0.009) {
      velocity.x = 0;
    }
    if (acceleration.y == 0 && velocity.y.abs() < 0.009) {
      velocity.y = 0;
    }
    position += velocity;
  }
}
