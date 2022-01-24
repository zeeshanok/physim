import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:physim/widgets/expander_button.dart';

class ColorEditor extends HookWidget {
  const ColorEditor({
    required this.onChanged,
    this.inputDecoration,
    required this.color,
    Key? key,
  }) : super(key: key);

  final Color color;
  final InputDecoration? inputDecoration;
  final void Function(Color color) onChanged;

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );
    final animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    useValueChanged<bool, void>(isExpanded.value, (_, __) {
      if (isExpanded.value) {
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
            axisAlignment: -1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                children: [
                  RepaintBoundary(child: ColorPickerSVGradient(color: color)),
                  const SizedBox(height: 4),
                  ColorPickerHSlider(hue: HSVColor.fromColor(color).hue)
                ],
              ),
            )),
        Row(
          children: [
            MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => isExpanded.value = !isExpanded.value,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: color, borderRadius: BorderRadius.circular(3)),
                  ),
                )),
            const SizedBox(width: 4),
            Expanded(
              child: TextFormField(
                initialValue:
                    color.value.toRadixString(16).substring(2).toUpperCase(),
                decoration: inputDecoration?.copyWith(prefixText: '#'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"^[a-f0-9]{0,6}$",
                      caseSensitive: false, multiLine: false))
                ],
                cursorWidth: 1,
                onChanged: (s) {
                  final c = int.tryParse(s, radix: 16);
                  if (c != null) {
                    final color = Color(0xFF000000 | c);
                    onChanged(color);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            ExpanderButton(
                isExpanded: isExpanded.value,
                onPressed: () => isExpanded.value = !isExpanded.value)
          ],
        ),
      ],
    );
  }
}

class ColorPickerSVGradient extends StatelessWidget {
  ColorPickerSVGradient({
    required Color color,
    Key? key,
  })  : color = HSVColor.fromColor(color),
        super(key: key);

  final HSVColor color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 100),
      painter: ColorPickerSVGradientPainter(color),
    );
  }
}

class ColorPickerSVGradientPainter extends CustomPainter {
  final HSVColor hsvColor;

  ColorPickerSVGradientPainter(this.hsvColor);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
        center: size.center(Offset.zero),
        width: size.width,
        height: size.height);
    final shaderHorizontal = LinearGradient(colors: [
      Colors.white,
      HSVColor.fromAHSV(1, hsvColor.hue, 1, 1).toColor()
    ]).createShader(rect);

    final shaderVertical = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.transparent, Colors.black],
    ).createShader(rect);

    canvas.drawRect(
        rect,
        Paint()
          ..shader = shaderHorizontal
          ..style = PaintingStyle.fill);
    canvas.drawRect(
        rect,
        Paint()
          ..shader = shaderVertical
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant ColorPickerSVGradientPainter oldDelegate) =>
      oldDelegate.hsvColor != hsvColor;
}

class ColorPickerHSlider extends StatelessWidget {
  const ColorPickerHSlider({Key? key, required this.hue}) : super(key: key);

  final double hue;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 12),
      painter: ColorPickerHSliderPainter(),
    );
  }
}

class ColorPickerHSliderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height / 2;
    final rect = Rect.fromLTWH(0, 0, size.width, h);
    final shader = LinearGradient(
            colors: List.generate(
                360, (i) => HSVColor.fromAHSV(1, i.toDouble(), 1, 1).toColor()))
        .createShader(rect);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = shader;

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant ColorPickerHSliderPainter oldDelegate) => false;
}
