import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_ml_kit_example/Provider/provider.dart';
import 'dart:ui' as ui;

import 'coordinates_translator.dart';

class ObjectDetectorPainter extends CustomPainter {
  ObjectDetectorPainter(this._objects, this.rotation, this.absoluteSize);

  final List<DetectedObject> _objects;
  final Size absoluteSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.lightGreenAccent;

    final Paint background = Paint()..color = Color(0x99000000);

    for (DetectedObject detectedObject in _objects) {
      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
            textAlign: TextAlign.left,
            fontSize: 16,
            textDirection: TextDirection.ltr),
      );
      builder.pushStyle(
          ui.TextStyle(color: Colors.lightGreenAccent, background: background));

      for (Label label in detectedObject.getLabels()) {
        //text view
        builder.addText('${label.getText()} ${label.getConfidence()} ${detectedObject.getBoundinBox()}\n');
      }

      Rect a =  detectedObject.getBoundinBox();

      //Rect getBoundingBox() => a;

      builder.pop();

      final left = translateX(
          detectedObject.getBoundinBox().left, rotation, size, absoluteSize);
      final top = translateY(
          detectedObject.getBoundinBox().top, rotation, size, absoluteSize);
      final right = translateX(
          detectedObject.getBoundinBox().right, rotation, size, absoluteSize);
      final bottom = translateY(
          detectedObject.getBoundinBox().bottom, rotation, size, absoluteSize);

      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paint,
      );

      canvas.drawParagraph(
        builder.build()
          ..layout(ParagraphConstraints(
            width: right - left,
          )),
        Offset(left, top),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
