import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:physim/game/game.dart';
import 'package:physim/widgets/editsection.dart';
import 'package:physim/widgets/roundediconbutton.dart';
import 'package:physim/widgets/toolbox.dart';

const windowBorder = Color(0xFF0000FF);

void main() {
  final getIt = GetIt.instance;
  getIt.registerSingleton<Game>(Game());

  runApp(MaterialApp(
    home: const HomePage(),
    theme: ThemeData.dark().copyWith(
      scrollbarTheme: scrollTheme,
    ),
  ));

  doWhenWindowReady(() {
    const size = Size(1000, 600);
    appWindow.size = appWindow.minSize = size;
    appWindow.alignment = Alignment.center;
    appWindow.title = "Physim";
    appWindow.show();
  });
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FocusNode focusNode = FocusNode();

  final game = GetIt.instance<Game>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF090909),
        body: Column(
          children: [
            SizedBox(
              height: 30,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  MoveWindow(
                      child: const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Physics Simulator',
                            style: TextStyle(color: Colors.grey),
                          ))),
                  const Align(
                      alignment: Alignment.centerRight, child: WindowButtons()),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
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
                      child: EditSection(),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundedIconButton(
                    onPressed: () => setState(game.togglePause),
                    icon: Icon((game.paused ?? false)
                        ? Icons.play_arrow
                        : Icons.pause),
                  ),
                  const SizedBox(width: 8),
                  RoundedIconButton(
                      onPressed: game.clearAllBalls,
                      icon: const Icon(Icons.delete))
                ],
              ),
            )
          ],
        ));
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

final scrollTheme = ScrollbarThemeData(
  thumbColor: MaterialStateProperty.resolveWith((states) =>
      states.any({MaterialState.hovered, MaterialState.pressed}.contains)
          ? Colors.white.withAlpha(230)
          : Colors.white.withAlpha(100)),
  thickness: MaterialStateProperty.resolveWith(
    (states) => states.contains(MaterialState.hovered) ? 4 : 1,
  ),
  mainAxisMargin: 0,
  crossAxisMargin: 4,
);

final defaultStyle = ButtonStyle(
  splashFactory: NoSplash.splashFactory,
  foregroundColor: MaterialStateProperty.all(Colors.white),
  shadowColor: MaterialStateProperty.all(Colors.transparent),
  overlayColor: MaterialStateProperty.all(Colors.transparent),
  side: MaterialStateProperty.all(BorderSide.none),
  shape: MaterialStateProperty.all(
      const ContinuousRectangleBorder(borderRadius: BorderRadius.zero)),
  minimumSize: MaterialStateProperty.all(const Size(45, 25)),
  padding: MaterialStateProperty.all(EdgeInsets.zero),
  elevation: MaterialStateProperty.all(0),
);

final closeStyle = defaultStyle.copyWith(
  backgroundColor: MaterialStateProperty.resolveWith((states) {
    if (states.contains(MaterialState.pressed)) {
      return Colors.red[600];
    }
    if (states.contains(MaterialState.hovered)) {
      return Colors.red;
    }
    return Colors.transparent;
  }),
);

final maximizeStyle = defaultStyle.copyWith(
  backgroundColor: MaterialStateProperty.resolveWith((states) {
    if (states.contains(MaterialState.pressed)) {
      return Colors.grey[700];
    }
    if (states.contains(MaterialState.hovered)) {
      return Colors.grey[800];
    }
    return Colors.transparent;
  }),
);

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: const [
        MinimizeWinButton(),
        MaximizeWinButton(),
        CloseWinButton(),
      ],
    );
  }
}

class MinimizeWinButton extends StatelessWidget {
  const MinimizeWinButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => appWindow.minimize(),
      child: const Icon(
        Icons.remove,
        size: 16,
      ),
      style: maximizeStyle,
    );
  }
}

class MaximizeWinButton extends StatelessWidget {
  const MaximizeWinButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => appWindow.maximizeOrRestore(),
      child: const Icon(
        Icons.crop_square,
        size: 16,
      ),
      style: maximizeStyle,
    );
  }
}

class CloseWinButton extends StatelessWidget {
  const CloseWinButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => appWindow.close(),
      child: const Icon(
        Icons.close,
        size: 16,
      ),
      style: closeStyle,
    );
  }
}
