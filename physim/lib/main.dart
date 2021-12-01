import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:physim/game/game.dart';
import 'package:physim/widgets/editsection.dart';
import 'package:physim/widgets/roundediconbutton.dart';
import 'package:physim/widgets/toolbox.dart';

void main() {
  final getIt = GetIt.instance;
  getIt.registerSingleton<Game>(Game());

  runApp(MaterialApp(
    home: const HomePage(),
    theme: ThemeData.dark(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Toolbox(),
            ),
            const Expanded(child: GameWindow()),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: SizedBox(
                width: 300,
                child: EditSection(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class GameWindow extends StatefulWidget {
  const GameWindow({Key? key}) : super(key: key);

  @override
  _GameWindowState createState() => _GameWindowState();
}

class _GameWindowState extends State<GameWindow> {
  final focusNode = FocusNode();

  final game = GetIt.instance<Game>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: FocusableActionDetector(
            shortcuts: <ShortcutActivator, Intent>{
              LogicalKeySet(LogicalKeyboardKey.space):
                  const TogglePauseIntent(),
            },
            actions: <Type, Action<Intent>>{
              TogglePauseIntent: CallbackAction<TogglePauseIntent>(
                  onInvoke: (_) => setState(game.togglePause)),
              AddBallIntent:
                  CallbackAction<AddBallIntent>(onInvoke: (_) => game.addBall())
            },
            autofocus: true,
            focusNode: focusNode,
            descendantsAreFocusable: false,
            child: MouseRegion(
              onHover: game.onHover,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (_) {
                  game.onMouseClick();
                  focusNode.requestFocus();
                },
                onPanUpdate: (e) {
                  game.onMouseClick(e.localPosition);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[900]!),
                          borderRadius: BorderRadius.circular(3)),
                      child: GameWidgetRender(game: game),
                    ),
                    if (game.paused ?? false)
                      Icon(
                        Icons.pause_circle_filled_rounded,
                        size: 50,
                        color: Colors.white.withAlpha(150),
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoundedIconButton(
              onPressed: () => setState(game.togglePause),
              icon:
                  Icon((game.paused ?? false) ? Icons.play_arrow : Icons.pause),
            ),
            const SizedBox(width: 8),
            RoundedIconButton(
                onPressed: game.clearAllBalls, icon: const Icon(Icons.delete))
          ],
        )
      ],
    );
  }
}

class TogglePauseIntent extends Intent {
  const TogglePauseIntent();
}

class AddBallIntent extends Intent {
  const AddBallIntent();
}
