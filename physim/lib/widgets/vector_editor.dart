import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:physim/widgets/expander_button.dart';
import 'package:physim/widgets/roundediconbutton.dart';
import 'package:vector_math/vector_math.dart' hide Colors;
import 'package:physim/utils.dart';

class Vector2Editor extends HookWidget {
  final List<TextInputFormatter>? inputFormatters;
  final InputDecoration? inputDecoration;

  const Vector2Editor({
    this.inputDecoration,
    this.inputFormatters,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vector = useState(Vector2(0, 0));

    final isEditingExpanded = useState(false);
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );
    final animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    useValueChanged<bool, void>(isEditingExpanded.value, (_, __) {
      if (isEditingExpanded.value) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizeTransition(
          sizeFactor: animation,
          axis: Axis.vertical,
          axisAlignment: 1,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Vector2GraphicalEditor(
              vector: vector.value,
              inputDecoration: inputDecoration,
              onAngleChanged: (angle) {
                final mag = vector.value.distanceTo(Vector2.zero());
                vector.value = Vector2(mag * cos(angle), mag * sin(angle));
              },
              onMagnitudeChanged: (mag) {
                final angle = vector.value.angleToSigned(Vector2(1, 0));
                vector.value = Vector2(mag * cos(angle), mag * sin(angle));
              },
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                cursorWidth: 1,
                initialValue: vector.value.x.toString(),
                onChanged: (val) {
                  final n = double.tryParse(val);
                  if (n != null) {
                    vector.value = Vector2(n, vector.value.y);
                    debugPrint('updated x');
                  }
                },
                decoration: inputDecoration?.copyWith(
                  labelText: 'x',
                  suffix: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text('î'),
                  ),
                ),
                inputFormatters: inputFormatters,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                cursorWidth: 1,
                initialValue: vector.value.y.toString(),
                decoration: inputDecoration?.copyWith(
                  labelText: 'y',
                  suffix: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text('ĵ'),
                  ),
                ),
                inputFormatters: inputFormatters,
                onChanged: (val) {
                  final n = double.tryParse(val);
                  if (n != null) {
                    vector.value = Vector2(vector.value.x, n);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            ExpanderButton(
              isExpanded: isEditingExpanded.value,
              onPressed: () =>
                  isEditingExpanded.value = !isEditingExpanded.value,
            )
          ],
        ),
      ],
    );
  }
}

class Vector2GraphicalEditor extends HookWidget {
  final Vector2 vector;
  final InputDecoration? inputDecoration;
  final void Function(double) onMagnitudeChanged;
  final void Function(double) onAngleChanged;

  const Vector2GraphicalEditor({
    required this.vector,
    required this.onMagnitudeChanged,
    required this.onAngleChanged,
    this.inputDecoration,
    Key? key,
  }) : super(key: key);

  double resolveAngle(double angle, bool isRad) =>
      (isRad ? angle : angle * 180 / pi);

  @override
  Widget build(BuildContext context) {
    // final mText = useTextEditingController(
    //     text: vector.distanceTo(Vector2.zero()).toString());
    // final aText = useTextEditingController(
    //     text: Vector2(1, 0).angleToSigned(vector).toString());
    final isRad = useState(false);

    // useValueChanged<Vector2, void>(vector, (_, __) {
    //   mText.text = vector.distanceTo(Vector2.zero()).toString();
    //   final angle =
    //       resolveAngle(Vector2(1, 0).angleToSigned(vector), isRad.value)
    //           .toString();
    //   aText.text = angle;
    // });
    final magnitude = vector.distanceTo(Vector2.zero());
    final getAngle = useCallback(
      () => resolveAngle(Vector2(1, 0).angleToSigned(vector), isRad.value),
      [vector, isRad.value],
    );

    // useValueChanged<bool, void>(isRad.value, (_, __) {
    //   final rad = Vector2(1, 0).angleToSigned(vector);
    //    = resolveAngle(rad, isRad.value).toString();
    // });

    final labelStyle = TextStyle(color: Colors.grey[400]);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: CustomPaint(
            size: const Size(double.infinity, 100),
            painter: Vector2EditorPainter(vector: vector),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Magnitude', style: labelStyle),
              const SizedBox(height: 2),
              // TextFormField(
              //   controller: mText,
              //   decoration: inputDecoration,
              //   inputFormatters: [
              //     FilteringTextInputFormatter.allow(decimalRegExp)
              //   ],
              //   onChanged: (val) {
              //     final n = double.tryParse(val);
              //     if (n != null) {
              //       onMagnitudeChanged(n);
              //     }
              //   },
              // ),
              Text(magnitude.toString()),
              const SizedBox(height: 4),
              Text('Angle (${isRad.value ? "rad" : "°"})', style: labelStyle),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  text: getAngle().toString(),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => isRad.value = !isRad.value,
                ),
              )
              // TextFormField(
              //   controller: aText,
              //   decoration: inputDecoration?.copyWith(
              //     suffix: Padding(
              //       padding: const EdgeInsets.only(left: 4),
              //       child: ToggleText(
              //         text: isRad.value ? 'rad' : 'deg',
              //         onTap: () => isRad.value = !isRad.value,
              //       ),
              //     ),
              //     suffixStyle: TextStyle(
              //       color: Colors.white.withAlpha(100),
              //       fontSize: 14,
              //     ),
              //   ),
              // )
            ],
          ),
        ),
        const SizedBox(width: 4)
      ],
    );
  }
}

class Vector2EditorPainter extends CustomPainter {
  final Vector2 vector;

  const Vector2EditorPainter({required this.vector});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height / 2;
    final angle = vector.angleToSigned(Vector2(1, 0));
    final p = Offset(radius * cos(angle), radius * sin(angle));

    final paint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = 2;
    // horizontal
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    // vertical
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    canvas.drawArrow(
        start: center, end: center + p, headAngle: pi / 3, strokeWidth: 2);
  }

  @override
  bool shouldRepaint(covariant Vector2EditorPainter oldDelegate) =>
      vector != oldDelegate.vector;
}

class ToggleText extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  const ToggleText({Key? key, required this.onTap, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        recognizer: TapGestureRecognizer()..onTap = onTap,
        text: text,
      ),
    );
  }
}
