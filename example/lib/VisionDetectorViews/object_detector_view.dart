import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_ml_kit_example/Provider/provider.dart';
import 'package:provider/provider.dart';

import 'camera_view.dart';
import 'painters/object_detector_painter.dart';

class ObjectDetectorView extends StatefulWidget {
  @override
  _ObjectDetectorView createState() => _ObjectDetectorView();
}

class _ObjectDetectorView extends State<ObjectDetectorView> {
  LocalModel model = LocalModel("object_labeler.tflite");
  late ObjectDetector objectDetector;
  late InputImage inputImage;
  String? name;
  int score = 0;

  @override
  void initState() {
    Timer.periodic(
      Duration(milliseconds: 200),
      _onTimer,
    );
    objectDetector = GoogleMlKit.vision.objectDetector(
        CustomObjectDetectorOptions(model,
            trackMutipleObjects: true, classifyObjects: true));
    super.initState();
  }

  bool isBusy = false;
  CustomPaint? customPaint;

  @override
  void dispose() {
    objectDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CameraView(
          title: 'Object Detector',
          customPaint: customPaint,
          onImage: (inputImage) {
            processImage(inputImage);
          },
          initialDirection: CameraLensDirection.back,
        ),
        Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  //blurRadius: 1.0,
                  //spreadRadius: 1.0,
                  //offset: Offset(10, 10))
                ),
              ],
              border: Border.all(color: Colors.black, width: 1),
              //borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        Center(
          child: Consumer<ButtonProvider>(
            builder: (context, model, child) {
              return model.circleWidget(1);
            },
          ),
        ),
        Consumer<ButtonProvider>(
          builder: (context, model, child) {
            return Align(
              alignment: Alignment(0, 0.9),
              child: Container(
                height: 70.0,
                width: 70.0,
                child: FloatingActionButton(
                  child: Text(
                    "${model.score}",
                    style: TextStyle(
                      //fontSize: 18,
                    ),
                  ),
                  onPressed: () {
                    model.check += 1;
                    if(name == "Fish" || name == "Food"){
                      model.score += 1;
                    }
                    Future.delayed(Duration(milliseconds: 200))
                        .then((_) => model.check -= 1);
                    model.notify();
                  },
                ),
              ),
            );
          },
        ),
        Consumer<ButtonProvider>(
          builder: (context, model, child) {
            return Text("score: ${model.score}",
              style: TextStyle(
                fontSize: 10,
              ),);
          },
        ),
      ],
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final result = await objectDetector.processImage(inputImage);
    print(result);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null &&
        result.length > 0) {
      final painter = ObjectDetectorPainter(
          result,
          inputImage.inputImageData!.imageRotation,
          inputImage.inputImageData!.size);
      customPaint = CustomPaint(painter: painter);
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
    exchange(result);
    /*late Label label;
    for (DetectedObject detectedObject in result) {
      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
            textAlign: TextAlign.left,
            fontSize: 16,
            textDirection: TextDirection.ltr),
      );
      for (label in detectedObject.getLabels()) {
        //text view
        builder.addText(
            '${label.getText()} ${label.getConfidence()} ${detectedObject
                .getBoundinBox()}\n');
      }
    }
    return label.getText();*/
  }

  String? exchange(dynamic data){
    late Label label;
    for (DetectedObject detectedObject in data) {
      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
            textAlign: TextAlign.left,
            fontSize: 16,
            textDirection: TextDirection.ltr),
      );

      for (label in detectedObject.getLabels()) {
        //text view
        builder.addText(
            '${label.getText()} ${label.getConfidence()} ${detectedObject
                .getBoundinBox()}\n');
      }
      print(label.getText());
      name = label.getText();
      return label.getText();
    }
  }

  void _onTimer(Timer timer){
    processImage(inputImage);
    //name = exchange(processImage(inputImage));
    print(processImage(inputImage));
  }
}
