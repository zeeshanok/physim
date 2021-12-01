import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:physim/game/game.dart';
import 'package:physim/widgets/vector_editor.dart';
import 'package:vector_math/vector_math.dart' hide Colors;
import 'package:physim/entities/entity.dart';

final decimalRegExp = RegExp(r'^-?\d*([.,]?\d*)?$');
final _getIt = GetIt.instance;

class EditSection extends HookWidget {
  const EditSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final game = useListenable(_getIt<Game>());
    final selected = game.getSelected();
    final scrollController = useScrollController();

    return selected != null
        ? Scrollbar(
            controller: scrollController,
            thickness: 0.5,
            hoverThickness: 0.5,
            isAlwaysShown: true,
            child: ListView(
              controller: scrollController,
              children: buildFormList(selected),
            ),
          )
        : Container();
  }
}

List<Widget> buildFormList(Type type) {
  final map = toTypeMap(type)!;
  return [
    for (final i in map.entries)
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
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
        borderRadius: BorderRadius.circular(3));
    final d = InputDecoration(
        isCollapsed: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        enabledBorder: border,
        focusedBorder: border,
        disabledBorder: border,
        focusedErrorBorder: border,
        errorBorder: border);
    switch (type) {
      case int:
        return [
          TextField(
            decoration: d,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          )
        ];
      case double:
        return [
          TextField(
            decoration: d,
            inputFormatters: [FilteringTextInputFormatter.allow(decimalRegExp)],
          )
        ];
      case String:
        return [TextField(decoration: d)];
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
        return [Container(color: Colors.red, width: 50, height: 50)];

      case bool:
        return [Checkbox(value: true, onChanged: (_) {})];
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = buildField();
    assert(w != null, 'The type: `$type` cannot be used as a text field');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 4),
          w!.length > 1
              ? Row(
                  children: w
                      .map((e) => Expanded(
                            child: e,
                          ))
                      .toList())
              : w[0]
        ],
      ),
    );
  }
}
