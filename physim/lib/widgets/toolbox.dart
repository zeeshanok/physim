import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:physim/entities/ball.dart';
import 'package:physim/entities/box.dart';
import 'package:physim/game/game.dart';
import 'package:physim/widgets/roundediconbutton.dart';

final _getIt = GetIt.instance;

class Toolbox extends HookWidget {
  Toolbox({Key? key}) : super(key: key);

  final toolList = {
    null: const Icon(Icons.mouse),
    Ball: const Icon(Icons.circle),
    Box: const Icon(Icons.crop_square)
  };

  @override
  Widget build(BuildContext context) {
    final game = useListenable(_getIt<Game>());

    return Column(
      children: [
        for (final e in toolList.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: RoundedIconButton(
                onPressed: () => game.setSelected(e.key),
                icon: e.value,
                selected: e.key == game.getSelected()),
          )
      ],
    );
  }
}
