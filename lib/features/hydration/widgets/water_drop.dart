import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_colors.dart';

class WaterDrop extends StatelessWidget {
  const WaterDrop({
    this.color = AppColors.aqua,
    this.width = 42,
    this.height = 52,
    super.key,
  });

  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _WaterDropPainter(color),
    );
  }
}

class _WaterDropPainter extends CustomPainter {
  const _WaterDropPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..cubicTo(
        size.width * .86,
        size.height * .34,
        size.width,
        size.height * .58,
        size.width,
        size.height * .76,
      )
      ..cubicTo(
        size.width,
        size.height * .95,
        size.width * .78,
        size.height,
        size.width / 2,
        size.height,
      )
      ..cubicTo(
        size.width * .22,
        size.height,
        0,
        size.height * .95,
        0,
        size.height * .76,
      )
      ..cubicTo(
        0,
        size.height * .58,
        size.width * .14,
        size.height * .34,
        size.width / 2,
        0,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaterDropPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
