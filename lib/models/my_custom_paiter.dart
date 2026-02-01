import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:scribbl_clone/models/touch_point.dart';

class MyCustomPaiter extends CustomPainter {
  MyCustomPaiter({required this.pointslist});
  List<TouchPoint?> pointslist;
  List<Offset> OffsetPoints = [];

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    //Logic for points, if there is a points, we need to display points
    //if there is line,we need to connect the points

    for (int i = 0; i < pointslist.length - 1; i++) {
      if (pointslist[i] != null && pointslist[i + 1] != null) {
        canvas.drawLine(
          pointslist[i]!.points,
          pointslist[i + 1]!.points,
          pointslist[i]!.paint,
        );
      } else if (pointslist[i] != null && pointslist[i + 1] == null) {
        OffsetPoints.clear();
        OffsetPoints.add(pointslist[i]!.points);
        OffsetPoints.add(
          Offset(
            pointslist[i]!.points.dx + 0.1,
            pointslist[i]!.points.dy + 0.1,
          ),
        );
        canvas.drawPoints(ui.PointMode.points, OffsetPoints, pointslist[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
