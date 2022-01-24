import 'package:flutter/material.dart';
import 'package:physim/widgets/roundediconbutton.dart';

class ExpanderButton extends StatelessWidget {
  const ExpanderButton({
    Key? key,
    required this.isExpanded,
    required this.onPressed,
  }) : super(key: key);

  final bool isExpanded;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return RoundedIconButton(
      onPressed: onPressed,
      icon: Icon(
        isExpanded
            ? Icons.keyboard_arrow_up_rounded
            : Icons.keyboard_arrow_down_rounded,
        size: 15,
      ),
      height: 30,
      width: 30,
      selected: isExpanded,
    );
  }
}
