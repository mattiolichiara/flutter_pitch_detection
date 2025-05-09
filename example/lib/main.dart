import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_pitch_detection/flutter_pitch_detection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final pitchDetector = FlutterPitchDetection();
  StreamSubscription<Map<String, dynamic>>? _pitchSubscription;

  static const defaultSampleRate = 44100;
  static const defaultTolerance = 0.6;
  static const defaultPrecision = 0.8;
  static const defaultBufferSize = 8196;
  static const defaultA4Reference = 440.0;

  String note = "";
  int midiNote = 0;
  double frequency = 0;
  String noteOctave = "";
  int octave = 0;
  double toleranceCents = defaultTolerance;
  int bufferSize = defaultBufferSize;
  int sampleRate = defaultSampleRate;
  bool isRecording = false;
  bool isOnPitch = false;
  int accuracy = 0;
  double minPrecision = defaultPrecision;
  double volume = 0;
  double volumeDbFS = 0;
  Uint8List? pcmData;
  List<double>? streamData;
  double pitchDeviation = 0;
  double a4Reference = defaultA4Reference;

  @override
  void initState() {
    super.initState();
  }

  void onStartPressed() async {
    if (!isRecording) {
      try {
        await pitchDetector.startDetection();

        bool rec = await pitchDetector.isRecording();
        setState(() {
          isRecording = rec;
        });
        debugPrint("[START] Is Recording: $isRecording");

        pitchDetector.setParameters(
          toleranceCents: defaultTolerance,
          bufferSize: defaultBufferSize,
          sampleRate: defaultSampleRate,
          minPrecision: defaultPrecision,
          a4Reference: defaultA4Reference,
        );

        _pitchSubscription = pitchDetector.onPitchDetected.listen((data) async {
          final stream = await pitchDetector.getRawDataFromStream();
          final pcm = await pitchDetector.getRawPcmDataFromStream();

          setState(() {
            noteOctave = data['noteOctave'] ?? "";
            note = data['note'] ?? "";
            octave = data['octave'] ?? 0;
            midiNote = data['midiNote'] ?? 0;
            frequency = data['frequency'] ?? 0;

            accuracy = data['accuracy'] ?? 0;
            pitchDeviation = data['pitchDeviation'] ?? 0;
            isOnPitch = data['isOnPitch'] ?? false;
            volume = data['volume'] ?? 0;
            volumeDbFS = data['volumeDbFS'] ?? 0;

            toleranceCents = data['toleranceCents'] ?? defaultTolerance;
            bufferSize = data['bufferSize'] ?? defaultBufferSize;
            sampleRate = data['sampleRate'] ?? defaultSampleRate;
            minPrecision = data['minPrecision'] ?? defaultPrecision;
            minPrecision = data['minPrecision'] ?? defaultPrecision;
            a4Reference = data['a4Reference'] ?? defaultA4Reference;

            streamData = stream;
            // debugPrint("RAW DATA: $streamData");

            pcmData = pcm;
            // debugPrint("PCM DATA: $pcmData");
          });
        });
      } catch (e) {
        debugPrint("Start Recording Error: $e");
      }
    }
  }

  void onStopPressed() async {
    if (isRecording) {
      try {
        await _pitchSubscription?.cancel();
        _pitchSubscription = null;

        await pitchDetector.stopDetection();
        setState(() {
          isRecording = false;
        });

        debugPrint("[STOP] Is Recording: $isRecording");
        resetValues();
      } catch (e) {
        debugPrint("Stop Recording Error: $e");
      }
    }
  }

  void resetValues() {
    setState(() {
      note = "";
      midiNote = 0;
      frequency = 0;
      noteOctave = "";
      octave = 0;

      toleranceCents = defaultTolerance;
      bufferSize = defaultBufferSize;
      sampleRate = defaultSampleRate;
      minPrecision = defaultPrecision;
      a4Reference = defaultA4Reference;

      isRecording = false;
      accuracy = 0;
      pitchDeviation = 0;
      isOnPitch = false;
      volume = 0;
      volumeDbFS = 0;

      pcmData = null;
      streamData = null;
    });
  }

  Widget _startButton(Size size) {
    return SizedBox(
      height: size.height * 0.1,
      width: size.width * 0.1,
      child: IconButton(
        onPressed: onStartPressed,
        icon: Icon(Icons.play_arrow_rounded, color: Colors.black),
      ),
    );
  }

  Widget _stopButton(Size size) {
    return SizedBox(
      height: size.height * 0.1,
      width: size.width * 0.1,
      child: IconButton(
        onPressed: onStopPressed,
        icon: Icon(Icons.stop_rounded, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Pitch Detection')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //SizedBox(height: size.height * 0.3),
              Text("Pitch: $noteOctave", style: TextStyle(fontSize: 20)),
              Text("Note: $note", style: TextStyle(fontSize: 18)),
              Text("Octave: $octave", style: TextStyle(fontSize: 18)),
              Text("Midi Note: $midiNote", style: TextStyle(fontSize: 18)),
              Text(
                "Frequency: ${frequency.toStringAsFixed(2)} Hz",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: size.height * 0.02),
              Text("Accuracy: $accuracy%", style: TextStyle(fontSize: 18)),
              Text(
                "Pitch Deviation: $pitchDeviation",
                style: TextStyle(fontSize: 18),
              ),
              Text(
                "Volume: ${volume.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18),
              ),
              Text(
                "Volume from DbSF: ${volumeDbFS.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                "Tolerance: ${toleranceCents.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18),
              ),
              Text(
                "Min Precision: ${minPrecision.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18),
              ),
              Text("BufferSize: $bufferSize", style: TextStyle(fontSize: 16)),
              Text("SampleRate: $sampleRate", style: TextStyle(fontSize: 16)),
              Text(
                "A4 Reference: $a4Reference",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: size.height * 0.02),
              Text("IsRecording: $isRecording", style: TextStyle(fontSize: 16)),
              Text(
                "OnPitch",
                style: TextStyle(
                  fontSize: 20,
                  color: isOnPitch ? Colors.green : Colors.transparent,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              isRecording ? _stopButton(size) : _startButton(size),
            ],
          ),
        ),
      ),
    );
  }
}
