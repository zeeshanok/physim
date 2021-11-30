import 'dart:math';
import 'dart:ui';

import 'package:physim/entities/entity.dart';

mixin Collidable on Entity {
  Rect get collisionBounds;
  bool isCollidingWith(Point point);
}
