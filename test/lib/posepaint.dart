import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'test/coordinates_translator.dart';

class PosePainter extends CustomPainter {
  PosePainter(this.poses, this.absoluteImageSize, this.rotation);

  final List<Pose> poses;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.red;

    for (final pose in poses) {
      void paintCircle(PoseLandmarkType type, Paint paintType) {
        final PoseLandmark landmark = pose.landmarks[type]!;
        canvas.drawCircle(
            Offset(
              translateX(landmark.x, rotation, size, absoluteImageSize),
              translateY(landmark.y, rotation, size, absoluteImageSize),
            ),
            5,
            paintType);
      }

      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        canvas.drawLine(
            Offset(translateX(joint1.x, rotation, size, absoluteImageSize),
                translateY(joint1.y, rotation, size, absoluteImageSize)),
            Offset(translateX(joint2.x, rotation, size, absoluteImageSize),
                translateY(joint2.y, rotation, size, absoluteImageSize)),
            paintType);
      }

      //Draw left arms
      paintCircle(PoseLandmarkType.leftShoulder, paint);
      paintCircle(PoseLandmarkType.leftElbow, paint);
      paintCircle(PoseLandmarkType.leftWrist, paint);
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, paint);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, paint);

      //Draw left arms
      paintCircle(PoseLandmarkType.rightShoulder, paint);
      paintCircle(PoseLandmarkType.rightElbow, paint);
      paintCircle(PoseLandmarkType.rightWrist, paint);
      paintLine(
          PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, paint);
      paintLine(
          PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, paint);

      // //Draw legs
      // paintLine(
      //     PoseLandmarkType.leftHip, PoseLandmarkType.leftAnkle, leftPaint);
      // paintLine(
      //     PoseLandmarkType.rightHip, PoseLandmarkType.rightAnkle, rightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }
}
