import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_pitch_detection/flutter_pitch_detection.dart';
import 'package:flutter_pitch_detection/flutter_pitch_detection_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

//TODO get decibels
//TODO return pitch accuracy
//TODO add isOnPitch
//TODO fix permission issues

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterPitchDetectionPlugin = FlutterPitchDetection();
  StreamSubscription<Map<String, dynamic>>? _pitchSubscription;
  String note = "N";
  double frequency = 0;
  String noteOctave = "N0";
  int octave = 0;
  double toleranceCents = 0;
  int bufferSize = 0;
  int sampleRate = 0;
  bool isRecording = false;
  double decibels = 0;
  bool isOnPitch = false;
  int accuracy = 0;
  double minPrecision = 0;

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
    bool rec = await _flutterPitchDetectionPlugin.isRecording();
    debugPrint("[START] Is Recording: $rec");

    _flutterPitchDetectionPlugin.setToleranceCents(0.9);
    _flutterPitchDetectionPlugin.setBufferSize(8192);
    _flutterPitchDetectionPlugin.setSampleRate(44100);
    _flutterPitchDetectionPlugin.setParameters(toleranceCents: 0.6, bufferSize: 8192, sampleRate: 44100, minPrecision: 0.7);

    _pitchSubscription = FlutterPitchDetectionPlatform.instance.onPitchDetected.listen((event) async {
      //debugPrint("Stream on");

      final newNote = await _flutterPitchDetectionPlugin.getNote();
      final newFrequency = await _flutterPitchDetectionPlugin.getFrequency();
      final newNoteOctave = await _flutterPitchDetectionPlugin.printNoteOctave();
      final newOctave = await _flutterPitchDetectionPlugin.getOctave();
      final newToleranceCents = await _flutterPitchDetectionPlugin.getToleranceCents();
      final newDecibels = await _flutterPitchDetectionPlugin.getDecibels();
      final newBufferSize = await _flutterPitchDetectionPlugin.getBufferSize();
      final newSampleRate = await _flutterPitchDetectionPlugin.getSampleRate();
      final newIsRecording = await _flutterPitchDetectionPlugin.isRecording();
      final newMinPrecision = await _flutterPitchDetectionPlugin.getMinPrecision();
      final newAccuracy = await _flutterPitchDetectionPlugin.getAccuracy(toleranceCents);
      final newIsOnPitch = await _flutterPitchDetectionPlugin.isOnPitch(toleranceCents, minPrecision);

      setState(() {
        note = newNote;
        frequency = newFrequency;
        noteOctave = newNoteOctave;
        octave = newOctave;
        toleranceCents = newToleranceCents;
        bufferSize = newBufferSize;
        sampleRate = newSampleRate;
        isRecording = newIsRecording;
        decibels = newDecibels;
        accuracy = newAccuracy;
        minPrecision = newMinPrecision;
        isOnPitch = newIsOnPitch;
      });
    });
  }

  void onStopPressed() async {
    setState(() {
      isRecording = false;
    });

    await _flutterPitchDetectionPlugin.stopDetection();
    bool rec = await _flutterPitchDetectionPlugin.isRecording();
    debugPrint("[STOP] Is Recording: $rec");

    await _pitchSubscription?.cancel();
    _pitchSubscription = null;
    resetValues();
  }

  void resetValues() {
    setState(() {
      note = "N";
      frequency = 0;
      noteOctave = "N0";
      octave = 0;
      toleranceCents = 0;
      bufferSize = 0;
      sampleRate = 0;
      isRecording = false;
      accuracy = 0;
      isOnPitch = false;
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //SizedBox(height: size.height * 0.3),
              Text("Pitch: $noteOctave", style: TextStyle(fontSize: 20)),
              Text("Note: $note", style: TextStyle(fontSize: 18)),
              Text("Octave: $octave", style: TextStyle(fontSize: 18)),
              Text("Frequency: ${frequency.toStringAsFixed(2)} Hz", style: TextStyle(fontSize: 18)),
              Text("Accuracy: $accuracy%", style: TextStyle(fontSize: 18)),
              Text("Decibels: ${decibels.toStringAsFixed(2)} dB", style: TextStyle(fontSize: 18)),
              SizedBox(height: size.height * 0.02),
              Text("Tolerance: ${toleranceCents.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
              Text("Min Precision: ${minPrecision.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
              Text("BufferSize: $bufferSize", style: TextStyle(fontSize: 16)),
              Text("SampleRate: $sampleRate", style: TextStyle(fontSize: 16)),
              SizedBox(height: size.height * 0.02),
              Text("IsRecording: $isRecording", style: TextStyle(fontSize: 16)),
              //Text("OnPitch", style: TextStyle(fontSize: 16, color: accuracy > minPrecision ? Colors.green : Colors.transparent)),
              Text("OnPitch Boolean", style: TextStyle(fontSize: 16, color: isOnPitch ? Colors.green : Colors.transparent)),
              SizedBox(height: size.height * 0.01),
              isRecording ? _stopButton(size) : _startButton(size),
            ],
          ),
        ),
      ),
    );
  }
}
