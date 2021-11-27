import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:physim/game/game.dart';

void main() {
  final game = Game();
  runApp(GameWidget(game: game));
}

class GameWidget extends StatefulWidget {
  const GameWidget({Key? key, required this.game}) : super(key: key);
  final Game game;

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: MouseRegion(
        onHover: widget.game.onHover,
        child: RawKeyboardListener(
          focusNode: focusNode,
          autofocus: true,
          onKey: (event) {
            if (event.logicalKey == LogicalKeyboardKey.space &&
                event is RawKeyDownEvent) {
              setState(() => widget.game.togglePause());
            }
          },
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              GameWidgetRender(game: widget.game),
              if (widget.game.paused ?? false)
                const Text(
                  'Paused',
                  style: TextStyle(color: Colors.white),
                )
            ],
          ),
        ),
      ),
    );
  }
}
