import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:physim/entities/entity.dart';
import 'package:physim/game/game_loop.dart';
import 'package:vector_math/vector_math.dart';

class Game {
  late Rect bounds;
  GameLoop? gameLoop;

  Offset mouse = Offset.zero;

  bool? get paused => gameLoop?.paused;

  final List<Entity> entities;

  Game() : entities = [];

  void initialize() {
    entities.add(
        Ball(id: 1, radius: 20, position: Vector2(100, 100), hasGravity: true));
  }

  void update(double dt) {
    for (var element in entities) {
      element.update(dt);
    }
  }

  void render(Canvas canvas) {
    for (var entity in entities) {
      entity.render(canvas);
    }
  }

  void onHover(PointerHoverEvent event) {
    if (event.localPosition != Offset.zero) {
      mouse = event.localPosition;
    }
  }

  void togglePause() {
    final loop = gameLoop;
    if (loop != null) {
      if (loop.paused) {
        loop.resume();
      } else {
        loop.pause();
      }
    }
  }

  void setBounds(Rect bounds) {
    this.bounds = bounds;
    for (final entity in entities.whereType<Bounded>()) {
      entity.setBounds(bounds);
    }
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
    // context.canvas.save();
    // context.canvas.translate(offset.dx, offset.dy);
    game.render(context.canvas);
    // context.canvas.restore();
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    game.setBounds(Rect.fromLTWH(0, 0, size.width, size.height));
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
