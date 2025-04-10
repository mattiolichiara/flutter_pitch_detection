import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_pitch_detection/flutter_pitch_detection.dart';
import 'package:flutter_pitch_detection/flutter_pitch_detection_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterPitchDetectionPlugin = FlutterPitchDetection();
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    //initPlatformState();
  }

  // // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initPlatformState() async {
  //   String platformVersion;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   // We also handle the message potentially returning null.
  //   try {
  //     platformVersion =
  //         await _flutterPitchDetectionPlugin.getPlatformVersion() ?? 'Unknown platform version';
  //   } on PlatformException {
  //     platformVersion = 'Failed to get platform version.';
  //   }
  //
  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;
  //
  //   setState(() {
  //     _platformVersion = platformVersion;
  //   });
  // }



  Widget _startButton(Size size) {
    return SizedBox(
      height: size.height*0.1,
      width: size.width*0.1,
      child: IconButton(
        onPressed: () {
          setState(() {
            isRecording = !isRecording;
          });
        },
        icon: Icon(
          Icons.play_arrow_rounded,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _stopButton(Size size) {
    return SizedBox(
      height: size.height*0.1,
      width: size.width*0.1,
      child: IconButton(
        onPressed: () {
          setState(() {
            isRecording = !isRecording;
          });
        },
        icon: Icon(
          Icons.stop_rounded,
          color: Colors.black,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pitch Detection'),
        ),
        body: Center(
          child: Column(
            children: [
              !isRecording? _startButton(size) : _stopButton(size),
            ],
          ),
        ),
      ),
    );
  }
}
