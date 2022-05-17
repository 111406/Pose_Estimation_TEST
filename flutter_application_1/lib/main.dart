import 'dart:async';
import 'dart:math';
import 'package:flutter_application_1/chart_data.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'package:motion_sensors/motion_sensors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterTts flutterTts = FlutterTts();
  var _angleP = 0;
  var _angleR = 0;
  var _deltaSum = 0;
  var _times = 0;
  var _mode = "three";
  var _isAdded = false;
  var _displayAngle = 0;
  var _timer = 30;
  var _timerStart = false;
  final List<ChartData> _angleList = [];
  var _startTime = 0;

  @override
  void initState() {
    super.initState();
    motionSensors.accelerometer.listen((AccelerometerEvent event) {
      setState(() {
        calcAngles(event.x, event.y, event.z);
      });
    });
  }

  Future _s() async {
    await flutterTts.speak('$_times');
  }

  void setUpdateInterval(int interval) {
    motionSensors.accelerometerUpdateInterval = interval;
    setState(() {});
  }

  var period = const Duration(seconds: 1);

  void setTimerEvent() {
    _timerStart = true;
    _timer--;
    _startTime = DateTime.now().millisecondsSinceEpoch;
    Timer.periodic(period, (timer) {
      if (_timer < 1) {
        timer.cancel();
        _timerStart = false;
      } else {
        _timer--;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    setUpdateInterval(Duration.microsecondsPerSecond ~/ 60);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Motion Sensors'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('運動次數'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('$_times次'),
                ],
              ),
              const Text('當前角度'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('$_displayAngle°'),
                ],
              ),
              const Text('剩餘時間'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('$_timer'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16)),
                    onPressed: () {
                      setTimerEvent();
                      setState(() {
                        _mode = "three";
                        _times = 0;
                        _timer = 30;
                      });
                    },
                    child: const Text('三角肌群'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16)),
                    onPressed: () {
                      setTimerEvent();
                      setState(() {
                        _mode = "two";
                        _times = 0;
                        _timer = 30;
                      });
                    },
                    child: const Text('二頭肌群'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16)),
                    onPressed: () {
                      setTimerEvent();
                      setState(() {
                        _mode = "slide";
                        _times = 0;
                        _timer = 30;
                      });
                    },
                    child: const Text('滑牆運動'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void calcAngles(double accelX, double accelY, double accelZ) {
    var deltaP = 0, deltaR = 0;
    var pitch =
        (180 * atan2(accelX, sqrt(accelY * accelY + accelZ * accelZ)) / pi)
            .round();
    var roll =
        (180 * atan2(accelY, sqrt(accelX * accelX + accelZ * accelZ)) / pi)
            .round();

    if (_mode == "three") {
      _displayAngle = pitch;
      deltaP = pitch - _angleP;

      if (deltaP <= 0) {
        _deltaSum = 0;
        _isAdded = false;
      }

      if (!_isAdded) {
        if (deltaP >= 0) {
          _deltaSum += deltaP;
          deltaP = 0;
        }
      }

      _angleP = pitch.round();

      if (_deltaSum > 25 && deltaP < 20) {
        _times += 1;
        _s();
        _deltaSum = 0;
        _isAdded = true;
      }

      debugPrint("pitch: $pitch");
      debugPrint("deltaP: $deltaP");
      debugPrint("_deltaSum: $_deltaSum");
      debugPrint("_isAdded: $_isAdded");
    } else if (_mode == "two") {
      _displayAngle = roll;
      deltaR = roll - _angleR;

      if (deltaR >= 0) {
        _deltaSum += deltaR;
        deltaR = 0;
      } else {
        _deltaSum = 0;
      }

      _angleR = roll.round();

      if (_deltaSum > 55) {
        _times += 1;
        _s();
        _deltaSum = 0;
      }
    } else if (_mode == "slide") {
      _displayAngle = roll;
      deltaR = roll - _angleR;

      if (deltaR >= -5) {
        deltaR = deltaR >= 0 ? deltaR : 0;
        _deltaSum += deltaR;
        deltaR = 0;
      } else {
        _deltaSum = 0;
      }

      _angleR = roll.round();

      if (_deltaSum > 75) {
        _times += 1;
        _s();
        _deltaSum = 0;
      }
    }

    if (_timerStart) {
      int now = DateTime.now().millisecondsSinceEpoch;
      double sec = (now - _startTime) / 1000;
      var data = ChartData(sec, _displayAngle);
      _angleList.add(data);
    }
  }
}
