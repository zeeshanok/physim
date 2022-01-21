import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:physim/entities/ball.dart';
import 'package:physim/entities/box.dart';
import 'package:physim/entities/entity.dart';
import 'package:physim/entities/fluids/fluid.dart';
import 'package:physim/entities/fluids/fluid_particle.dart';
import 'package:physim/game/game_loop.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

class Game extends ChangeNotifier {
  int id = 0;

  late Rect screenBounds;
  GameLoop? gameLoop;
  double lastFrameTime = 1;
  double get fps => lastFrameTime == 0 ? 1 : 1 / lastFrameTime;

  Type? _selected;
  Type? getSelected<T extends Entity>() => _selected;
  void setSelected<T extends Entity>(Type? type) {
    _selected = type;
    notifyListeners();
  }

  Offset mouse = Offset.zero;

  bool? get paused => gameLoop?.paused;

  final List<Entity> entities;
  final Fluid fluid = Fluid(id: -2);

  int _lastEntityId = 0;
  int get lastEntityId {
    // try {
    //   return entities.where((e) => e.id != -1).last.id;
    // } catch (_) {}
    return _lastEntityId++;
  }

  Game() : entities = [];

  void initialize() {}

  void update(double dt) {
    lastFrameTime = dt;
    for (var element in entities) {
      element.update(dt);
    }
    fluid.update(dt);
  }

  void render(Canvas canvas) {
    for (var entity in entities) {
      entity.render(canvas);
    }
    fluid.render(canvas);
    if (_selected != null) {
      renderGhost(canvas, _selected!, mouse.toVector2());
    }
    final painter = TextPainter(
        text: TextSpan(text: "${fps.round()} FPS", children: [
          TextSpan(
              text: "\n${entities.length + fluid.particles.length} entities"),
        ]),
        textDirection: TextDirection.ltr);
    painter.layout();
    painter.paint(canvas, const Offset(10, 10));
    canvas.clipRect(
        Rect.fromLTWH(0, 0, screenBounds.width, screenBounds.height),
        clipOp: ClipOp.difference);
  }

  void onHover(PointerHoverEvent event) {
    if (event.localPosition != Offset.zero) {
      mouse = event.localPosition;
    }
  }

  void togglePause() {
    // final loop = gameLoop;
    // if (loop != null) {
    //   if (loop.paused) {
    //     loop.resume();
    //   } else {
    //     loop.pause();
    //   }
    // }
  }

  void setBounds(Rect bounds) {
    screenBounds = bounds;
    for (final entity in entities.whereType<MotionBoundary>()) {
      entity.setBounds(screenBounds);
    }
  }

  void onMouseClick([Offset? m]) {
    MotionBoundary? item;
    final mousePos = (m ?? mouse).toVector2();
    switch (_selected) {
      case Ball:
        item = Ball(
            position: mousePos,
            id: lastEntityId + 1,
            radius: 20,
            acceleration: Vector2(10, 10));
        break;
      case Box:
        item = Box(
            id: lastEntityId + 1,
            position: mousePos,
            width: 30,
            height: 30,
            acceleration: Vector2(10, 10),
            color: const Color(0xFFFFFFFF));
        break;
      case FluidParticle:
        fluid.addParticle(
            FluidParticle(id: lastEntityId + 1, position: mousePos)
              ..setBounds(screenBounds));

        break;
    }
    if (item != null) {
      item.setBounds(screenBounds);
      entities.add(item);
    }
  }

  void clearAllBalls() {
    entities.clear();
    fluid.particles.clear();
  }
}

class GameRenderBox extends RenderBox {
  final Game game;

  GameRenderBox({required this.game});

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    game.gameLoop = GameLoop((dt) {
      if (!attached) return;
      game.update(dt);
      markNeedsPaint();
    });
    game.initialize();
    game.gameLoop!.start();
  }

  @override
  void detach() {
    game.gameLoop?.dispose();
    game.gameLoop = null;
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);
    context.pushClipRect(needsCompositing, Offset.zero,
        Rect.fromLTWH(0, 0, size.width, size.height), (context, offset) {
      context.canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()..color = Colors.black);
      game.render(context.canvas);
    });
    context.canvas.restore();
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    game.setBounds(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }
}

class GameWidgetRender extends SingleChildRenderObjectWidget {
  final Game game;
  const GameWidgetRender({required this.game, Key? key}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return GameRenderBox(game: game);
  }
}
