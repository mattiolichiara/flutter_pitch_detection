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
  final _flutterPitchDetectionPlugin = FlutterPitchDetection();
  StreamSubscription<Map<String, dynamic>>? _pitchSubscription;
  String note = "ND";
  double frequency = 0;
  String noteOctave = "ND";
  int octave = 0;
  double accuracy = 0;
  int bufferSize = 0;
  int sampleRate = 0;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    //initPlatformState();
  }

  void onStartPressed() async {
    setState(() {
      isRecording = true;
    });

    await _flutterPitchDetectionPlugin.startDetection();
    // bool currentRecording = await _flutterPitchDetectionPlugin.isRecording();
    // debugPrint("[START] Is Recording: $currentRecording");

    _pitchSubscription = FlutterPitchDetectionPlatform.instance.onPitchDetected.listen((event) async {
      debugPrint("Stream on");

      final newNote = await _flutterPitchDetectionPlugin.getNote();
      final newFrequency = await _flutterPitchDetectionPlugin.getFrequency();
      final newNoteOctave = await _flutterPitchDetectionPlugin.printNoteOctave();
      final newOctave = await _flutterPitchDetectionPlugin.getOctave();
      final newAccuracy = await _flutterPitchDetectionPlugin.getAccuracy();
      final newBufferSize = await _flutterPitchDetectionPlugin.getBufferSize();
      final newSampleRate = await _flutterPitchDetectionPlugin.getSampleRate();
      final newIsRecording = await _flutterPitchDetectionPlugin.isRecording();

      setState(() {
        note = newNote;
        frequency = newFrequency;
        noteOctave = newNoteOctave;
        octave = newOctave;
        accuracy = newAccuracy;
        bufferSize = newBufferSize;
        sampleRate = newSampleRate;
        isRecording = newIsRecording;
      });
    });
  }

  void onStopPressed() async {
    setState(() {
      isRecording = false;
    });

    await _flutterPitchDetectionPlugin.stopDetection();
    debugPrint("[STOP] Is Recording: ${_flutterPitchDetectionPlugin.isRecording()}");

    await _pitchSubscription?.cancel();
    _pitchSubscription = null;
    resetValues();
  }

  void resetValues() {
    setState(() {
      note = "ND";
      frequency = 0;
      noteOctave = "ND";
      octave = 0;
      accuracy = 0;
      bufferSize = 0;
      sampleRate = 0;
      isRecording = false;
    });
  }

  Widget _startButton(Size size) {
    return SizedBox(
      height: size.height*0.1,
      width: size.width*0.1,
      child: IconButton(
        onPressed: onStartPressed,
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
        onPressed: onStopPressed,
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
              SizedBox(height: size.height * 0.3),
              Text("Note-Octave: $noteOctave", style: TextStyle(fontSize: 20)),
              Text("Note: $note", style: TextStyle(fontSize: 18)),
              Text("Octave: $octave", style: TextStyle(fontSize: 18)),
              Text("Frequency: ${frequency.toStringAsFixed(2)} Hz", style: TextStyle(fontSize: 18)),
              Text("Accuracy: ${accuracy.toStringAsFixed(2)} Hz", style: TextStyle(fontSize: 18)),
              Text("IsRecording: $isRecording", style: TextStyle(fontSize: 16)),
              Text("BufferSize: $bufferSize", style: TextStyle(fontSize: 16)),
              Text("SampleRate: $sampleRate", style: TextStyle(fontSize: 16)),
              SizedBox(height: size.height * 0.1),
              isRecording ? _stopButton(size) : _startButton(size),
            ],
          ),
        ),
      ),
    );
  }
}
