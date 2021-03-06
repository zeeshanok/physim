import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:physim/game/game.dart';
import 'package:physim/utils.dart';
import 'package:physim/widgets/color_editor.dart';
import 'package:physim/widgets/vector_editor.dart';
import 'package:vector_math/vector_math.dart' hide Colors;
import 'package:physim/entities/entity.dart';

final _getIt = GetIt.instance;

class EditSection extends HookWidget {
  const EditSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final game = useListenable(_getIt<Game>());
    final selected = game.getSelected();
    final animationController =
        useAnimationController(duration: const Duration(milliseconds: 200));
    final animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    useValueChanged<Type?, void>(selected, (_, __) {
      if (selected == null) {
        animationController.reverse();
      } else {
        animationController.forward();
      }
    });

    return SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1,
        axis: Axis.horizontal,
        child: SizedBox(
            width: 300,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              child: selected != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(selected.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                            child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: buildFormList(selected),
                        ))
                      ],
                    )
                  : Container(),
            )));
  }
}

List<Widget> buildFormList(Type type) {
  final map = toTypeMap(type);
  return [
    for (final i in map.entries)
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 6, 10, 6),
        child: TypeDependentFormField(label: i.key, type: i.value),
      )
  ];
}

class TypeDependentFormField extends HookWidget {
  final Type type;
  final String label;

  const TypeDependentFormField(
      {Key? key, required this.type, required this.label})
      : super(key: key);

  List<Widget>? buildField() {
    final border = OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: Colors.grey[800]!),
      borderRadius: BorderRadius.circular(3),
    );
    final d = InputDecoration(
      isCollapsed: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      enabledBorder: border,
      focusedBorder: border,
      disabledBorder: border,
      focusedErrorBorder: border,
      errorBorder: border,
      suffixStyle: TextStyle(
        fontSize: 15,
        color: Colors.white.withAlpha(100),
      ),
    );
    switch (type) {
      case int:
        return [
          TextField(
            cursorWidth: 1,
            decoration: d,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          )
        ];
      case double:
        return [
          TextField(
            cursorWidth: 1,
            decoration: d,
            inputFormatters: [FilteringTextInputFormatter.allow(decimalRegExp)],
          )
        ];
      case String:
        return [
          TextField(
            cursorWidth: 1,
            decoration: d,
          )
        ];
      case Vector2:
        final decor =
            d.copyWith(floatingLabelBehavior: FloatingLabelBehavior.never);
        final formatters = [FilteringTextInputFormatter.allow(decimalRegExp)];
        return [
          Vector2Editor(
            inputDecoration: decor,
            inputFormatters: formatters,
          )
        ];

      case Color:
        return [
          ColorEditor(
            onChanged: (c) {},
            color: const Color(0xFFFF149D),
            inputDecoration: d,
          )
        ];

      case bool:
        return [Checkbox(value: true, onChanged: (_) {})];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final w = buildField();
    assert(w != null, 'The type: `$type` cannot be used as a text field');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        w!.length > 1
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: w.map((e) => e).toList())
            : w[0]
      ],
    );
  }
}
