import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:test/test/pose_detector_view.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google ML Kit Demo App'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: RaisedButton(
            child: Text('Test'),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => TestPage()));
            },
          ),
        ),
      ),
    );
  }
}
