import 'dart:math';

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
  final pitchDetector = FlutterPitchDetection();
  StreamSubscription<Map<String, dynamic>>? _pitchSubscription;
  String note = "N";
  int midiNote = 0;
  double frequency = 0;
  String noteOctave = "N0";
  int octave = 0;
  double toleranceCents = 0;
  int bufferSize = 0;
  int sampleRate = 0;
  bool isRecording = false;
  bool isOnPitch = false;
  int accuracy = 0;
  double minPrecision = 0;
  double volume = 0;
  double volumeFromDbFS = 0;
  Uint8List? pcmData;
  List<double>? streamData;

  @override
  void initState() {
    super.initState();
  }

  void onStartPressed() async {
    setState(() {
      isRecording = true;
    });

    await pitchDetector.startDetection();
    bool rec = await pitchDetector.isRecording();
    debugPrint("[START] Is Recording: $rec");

    pitchDetector.setToleranceCents(0.9);
    pitchDetector.setBufferSize(8192);
    pitchDetector.setSampleRate(44100);
    pitchDetector.setParameters(toleranceCents: 0.6, bufferSize: 8192, sampleRate: 44100, minPrecision: 0.7);

    _pitchSubscription = FlutterPitchDetectionPlatform.instance.onPitchDetected.listen((event) async {
      //debugPrint("Stream on");

      final newNote = await pitchDetector.getNote();
      final newMidiNote = await pitchDetector.getMidiNote();
      final newFrequency = await pitchDetector.getFrequency();
      final newNoteOctave = await pitchDetector.printNoteOctave();
      final newOctave = await pitchDetector.getOctave();
      final newToleranceCents = await pitchDetector.getToleranceCents();
      final newBufferSize = await pitchDetector.getBufferSize();
      final newSampleRate = await pitchDetector.getSampleRate();
      final newIsRecording = await pitchDetector.isRecording();
      final newMinPrecision = await pitchDetector.getMinPrecision();
      final newAccuracy = await pitchDetector.getAccuracy(toleranceCents);
      final newIsOnPitch = await pitchDetector.isOnPitch(toleranceCents, minPrecision);
      final newVolume = await pitchDetector.getVolume();
      final newVolumeFromDbSF = await pitchDetector.getVolumeFromDbFS();
      final newPcmData = await pitchDetector.getRawPcmDataFromStream();
      final newStreamData = await pitchDetector.getRawDataFromStream();
      debugPrint("PCM DATA: $newPcmData");
      debugPrint("RAW DATA: $newStreamData");

      setState(() {
        note = newNote;
        midiNote = newMidiNote;
        frequency = newFrequency;
        noteOctave = newNoteOctave;
        octave = newOctave;
        toleranceCents = newToleranceCents;
        bufferSize = newBufferSize;
        sampleRate = newSampleRate;
        isRecording = newIsRecording;
        accuracy = newAccuracy;
        minPrecision = newMinPrecision;
        isOnPitch = newIsOnPitch;
        volume = newVolume;
        volumeFromDbFS = newVolumeFromDbSF;
        pcmData = newPcmData;
        streamData = newStreamData;
      });
    });
  }

  void onStopPressed() async {
    setState(() {
      isRecording = false;
    });

    await pitchDetector.stopDetection();
    bool rec = await pitchDetector.isRecording();
    debugPrint("[STOP] Is Recording: $rec");

    await _pitchSubscription?.cancel();
    _pitchSubscription = null;
    resetValues();
  }

  void resetValues() {
    setState(() {
      note = "N";
      midiNote = 0;
      frequency = 0;
      noteOctave = "N0";
      octave = 0;
      toleranceCents = 0;
      bufferSize = 0;
      sampleRate = 0;
      isRecording = false;
      accuracy = 0;
      isOnPitch = false;
      volume = 0;
      volumeFromDbFS = 0;
      pcmData = null;
      streamData = null;
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
              Text("Midi Note: $midiNote", style: TextStyle(fontSize: 18)),
              Text("Octave: $octave", style: TextStyle(fontSize: 18)),
              Text("Frequency: ${frequency.toStringAsFixed(2)} Hz", style: TextStyle(fontSize: 18)),
              Text("Accuracy: $accuracy%", style: TextStyle(fontSize: 18)),
              Text("Volume: ${volume.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
              Text("Volume from DbSF: ${volumeFromDbFS.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
              SizedBox(height: size.height * 0.02),
              Text("Tolerance: ${toleranceCents.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
              Text("Min Precision: ${minPrecision.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
              Text("BufferSize: $bufferSize", style: TextStyle(fontSize: 16)),
              Text("SampleRate: $sampleRate", style: TextStyle(fontSize: 16)),
              SizedBox(height: size.height * 0.02),
              Text("IsRecording: $isRecording", style: TextStyle(fontSize: 16)),
              //Text("OnPitch", style: TextStyle(fontSize: 16, color: accuracy > minPrecision ? Colors.green : Colors.transparent)),
              Text("OnPitch", style: TextStyle(fontSize: 20, color: isOnPitch ? Colors.green : Colors.transparent)),
              SizedBox(height: size.height * 0.01),
              isRecording ? _stopButton(size) : _startButton(size),
            ],
          ),
        ),
      ),
    );
  }
}





