import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const SensorPocApplication());
  }
}

class SensorPocApplication extends StatefulWidget {
  const SensorPocApplication({super.key});

  static const methodChannel = MethodChannel(
    'com.example.sensor_poc_application',
  );

  @override
  State<SensorPocApplication> createState() => _SensorPocApplicationState();
}

class _SensorPocApplicationState extends State<SensorPocApplication> {
  double posX = 0;
  double posY = 0;
  final double ballSize = 50;

  Size screenSize = Size.zero;

  @override
  void initState() {

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      screenSize = MediaQuery.sizeOf(context);
      SensorPocApplication.methodChannel.setMethodCallHandler((call) async {
        if (call.method == 'sensorUpdate') {
          double accelX = call.arguments[0];
          double accelY = call.arguments[1];

          setState(() {
            posX += (-accelX * 2);
            posY += (accelY * 2);

            posX = posX.clamp(0.0, MediaQuery.sizeOf(context).width - ballSize);
            posY = posY.clamp(
              0.0,
              MediaQuery.sizeOf(context).height - ballSize,
            );
          });
        } else if (call.method == "a") {
          log("log : ${call.arguments}");
        }
      });
    });

    SensorPocApplication.methodChannel.invokeMethod('startSensorUpdate');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: posX,
            top: posY,
            child: Container(
              width: ballSize,
              height: ballSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
