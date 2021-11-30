import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:physim/entities/ball.dart';
import 'package:physim/entities/box.dart';
import 'package:physim/entities/entity.dart';
import 'package:physim/game/game_loop.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

class Game extends ChangeNotifier {
  int id = 0;

  late Rect screenBounds;
  GameLoop? gameLoop;
  double lastFrameTime = 1;
  double get fps => lastFrameTime == 0 ? 1 : 1 / lastFrameTime;

  Type _selected;
  Type getSelected<T extends Entity>() => _selected;
  void setSelected<T extends Entity>(Type type) {
    _selected = type;
    notifyListeners();
  }

  Offset mouse = Offset.zero;

  bool? get paused => gameLoop?.paused;

  final List<Entity> entities;
  int? get lastEntityId {
    try {
      return entities.where((e) => e.id != -1).last.id;
    } catch (_) {}
  }

  Game()
      : entities = [],
        _selected = Ball;

  void initialize() {}

  void update(double dt) {
    lastFrameTime = dt;
    for (var element in entities) {
      element.update(dt);
    }
  }

  void render(Canvas canvas) {
    for (var entity in entities) {
      entity.render(canvas);
    }
    renderGhost(canvas, _selected, mouse.toVector2());
    final painter = TextPainter(
        text: TextSpan(text: "${fps.round()} FPS", children: [
          TextSpan(text: "\n${entities.length} entities"),
        ]),
        textDirection: TextDirection.ltr);
    painter.layout();
    painter.paint(canvas, const Offset(10, 10));
    canvas.clipRect(
        Rect.fromLTWH(0, 0, screenBounds.width, screenBounds.height),
        clipOp: ClipOp.difference);
  }

  void onHover(PointerHoverEvent event) {
    // if (event.localPosition != Offset.zero) {
    mouse = event.localPosition;
    // }
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
    debugPrint('click');
    final e = (_selected == Ball
        ? Ball(
            position: (m ?? mouse).toVector2(),
            id: (lastEntityId ?? 1) + 1,
            radius: 20,
            acceleration: Vector2(0.3, 0.2),
          )
        : Box(
            id: (lastEntityId ?? 1) + 1,
            position: (m ?? mouse).toVector2(),
            width: 30,
            height: 30,
            acceleration: Vector2(0.2, 0.1),
            color: const Color(0xFFFFFFFF)))
      ..setBounds(screenBounds);
    entities.add(e);
  }

  void addBall() {
    entities.add(Ball(
        position: Vector2(screenBounds.width / 2, screenBounds.height / 2),
        id: (lastEntityId ?? 1) + 1,
        radius: 10,
        acceleration: Vector2(0, 0.01))
      ..setBounds(screenBounds));
  }

  void clearAllBalls() {
    entities.clear();
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
    context.canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.black);
    game.render(context.canvas);
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
