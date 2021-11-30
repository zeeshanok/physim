import 'package:flutter/material.dart';

class RoundedIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final bool selected;
  final double sideLength;

  const RoundedIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    bool? selected,
    this.sideLength = 60,
  })  : selected = selected ?? false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: icon,
      style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size.square(sideLength)),
          shadowColor: MaterialStateProperty.all(Colors.transparent),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (selected || states.contains(MaterialState.pressed)) {
              return Colors.transparent;
            }
            if (states.any(focusStates.contains)) {
              return Colors.grey[900];
            }
            return Colors.transparent;
          }),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (selected) {
              return Theme.of(context).colorScheme.primary;
            }
            if (states.any(focusStates.contains)) {
              return Colors.grey[600];
            }
            return Colors.grey[800];
          }),
          side: MaterialStateProperty.resolveWith((states) {
            return BorderSide(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : states.any(focusStates.contains)
                        ? Colors.grey[900]!
                        : Colors.grey[850]!);
          }),
          splashFactory: NoSplash.splashFactory),
    );
  }
}

final focusStates = {
  MaterialState.hovered,
  MaterialState.focused,
  MaterialState.selected,
};
