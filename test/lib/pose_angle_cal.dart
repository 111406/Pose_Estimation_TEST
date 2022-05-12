import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseAngleCal extends StatefulWidget {
  const PoseAngleCal({
    Key? key,
    required this.poses,
  }) : super(key: key);

  final List<Pose> poses;

  @override
  State<PoseAngleCal> createState() => _PoseAngleCalState();
}

class _PoseAngleCalState extends State<PoseAngleCal> {
  String? _angle;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(_angle!),
    );
  }
}
