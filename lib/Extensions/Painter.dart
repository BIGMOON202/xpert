import 'dart:math' as math;

import 'package:flutter/material.dart';

class CurvePainter extends CustomPainter {
  final double angle;
  final Color color;

  CurvePainter({
    required this.color,
    this.angle = 140,
  });

  double _coef = 4;
  @override
  void paint(Canvas canvas, Size size) {
    final Paint shdowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = _coef;
    final Offset shdowPaintCenter = Offset(size.width / 2, size.height / 2);
    final double shdowPaintRadius = math.min(size.width / 2, size.height / 2) - (_coef / 2);
    // canvas.drawArc(Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius), degreeToRadians(278),
    //     degreeToRadians(360 - (365 - angle)), false, shdowPaint);

    shdowPaint.color = Colors.white.withOpacity(0.1);
    shdowPaint.strokeWidth = 2;
    canvas.drawArc(Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278), degreeToRadians(360), false, shdowPaint);

    shdowPaint.color = color;
    shdowPaint.strokeWidth = 2;
    canvas.drawArc(Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278), degreeToRadians(360 - (365 - angle)), false, shdowPaint);

    // shdowPaint.color = Colors.grey.withOpacity(0.2);
    // shdowPaint.strokeWidth = 20;
    // canvas.drawArc(Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius), degreeToRadians(278),
    //     degreeToRadians(360 - (365 - angle)), false, shdowPaint);
    //
    // shdowPaint.color = Colors.grey.withOpacity(0.1);
    // shdowPaint.strokeWidth = 22;
    // canvas.drawArc(Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius), degreeToRadians(278),
    //     degreeToRadians(360 - (365 - angle)), false, shdowPaint);

    // final Rect rect = Rect.fromLTWH(0.0, 0.0, size.width, size.width);
    // final SweepGradient gradient = SweepGradient(
    //   startAngle: degreeToRadians(268),
    //   endAngle: degreeToRadians(270.0 + 360),
    //   tileMode: TileMode.repeated,
    //   colors: colors,
    // );
    // final Paint paint = Paint()
    //   ..shader = gradient.createShader(rect)
    //   ..strokeCap = StrokeCap.round // StrokeCap.round is not recommended.
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 4;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width / 2, size.height / 2) - (_coef / 2);

    // canvas.drawArc(Rect.fromCircle(center: center, radius: radius), degreeToRadians(278),
    // degreeToRadians(360 - (365 - angle)), false, paint);

    const SweepGradient gradient1 = SweepGradient(
      tileMode: TileMode.repeated,
      colors: <Color>[Colors.white, Colors.white],
    );

    // final Paint cPaint = Paint();
    // cPaint.shader = gradient1.createShader(rect);
    // cPaint.color = Colors.white;
    // cPaint.strokeWidth = _coef / 2;
    // canvas.save();

    final double centerToCircle = size.width / 2;
    canvas.save();

    canvas.translate(centerToCircle, centerToCircle);
    canvas.rotate(degreeToRadians(angle + 2));

    canvas.save();
    canvas.translate(0.0, -centerToCircle + _coef / 2);
    // canvas.drawCircle(const Offset(0, 0), _coef / 5, cPaint);

    // canvas.restore();
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double degreeToRadians(double degree) {
    final double radian = (math.pi / 180) * degree;
    return radian;
  }
}
