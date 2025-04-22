import 'package:flutter/material.dart';

class SignToTextLogic extends CustomPainter {
  final List<Offset> landmarks;

  SignToTextLogic(this.landmarks);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 4
      ..style = PaintingStyle.fill;

    for (final point in landmarks) {
      canvas.drawCircle(point, 6, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
