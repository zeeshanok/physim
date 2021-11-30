import 'dart:ui';

import 'package:physim/entities/mixins/collidable.dart';
import 'package:physim/entities/mixins/linear_motion.dart';

mixin MotionBoundary on LinearMotion, Collidable {
  Rect bounds = const Rect.fromLTWH(0, 0, 1000, 1000);

  void setBounds(Rect bounds) => this.bounds = bounds;

  double getValidMaxY(double maxY);
  double getValidMinY(double minY);
  double getValidMaxX(double maxX);
  double getValidMinX(double minX);

  void fixBoundsCollision() {
    final cBounds = collisionBounds;
    if (cBounds.bottom >= bounds.bottom) {
      velocity.y *= -1;
      position.y = getValidMaxY(bounds.bottom);
    } else if (cBounds.top <= bounds.top) {
      velocity.y *= -1;
      position.y = getValidMinY(bounds.top);
    }
    if (cBounds.right >= bounds.right) {
      velocity.x *= -1;
      position.x = getValidMaxX(bounds.right);
    } else if (cBounds.left <= bounds.left) {
      velocity.x *= -1;
      position.x = getValidMinX(bounds.left);
    }
  }
}
