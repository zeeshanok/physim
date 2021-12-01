import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:physim/widgets/roundediconbutton.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

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
            child: Vector2GraphicalEditor(vector: vector.value),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                initialValue: vector.value.x.toString(),
                onChanged: (val) {
                  final n = double.tryParse(val);
                  if (n != null) {
                    vector.value = Vector2(n, vector.value.y);
                  }
                },
                decoration: inputDecoration?.copyWith(
                  labelText: 'x',
                ),
                inputFormatters: inputFormatters,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: vector.value.y.toString(),
                decoration: inputDecoration?.copyWith(labelText: 'y'),
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
            RoundedIconButton(
              onPressed: () {
                isEditingExpanded.value = !isEditingExpanded.value;
              },
              icon: const Icon(
                Icons.edit,
                size: 15,
              ),
              sideLength: 30,
              selected: isEditingExpanded.value,
            )
          ],
        ),
      ],
    );
  }
}

class Vector2GraphicalEditor extends HookWidget {
  final Vector2 vector;
  const Vector2GraphicalEditor({required this.vector, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 100),
      painter: Vector2EditorPainter(vector: vector),
    );
  }
}

class Vector2EditorPainter extends CustomPainter {
  final Vector2 vector;

  const Vector2EditorPainter({required this.vector});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2) + const Offset(0, 1);
    final radius = size.height / 2;
    final angle = vector.angleToSigned(Vector2(1, 0));
    final p = Offset(radius * cos(angle), radius * sin(angle));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(
        center,
        center + p,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant Vector2EditorPainter oldDelegate) =>
      vector != oldDelegate.vector;
}
