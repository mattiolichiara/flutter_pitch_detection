import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pitch_detection/flutter_pitch_detection.dart';
import 'package:flutter_pitch_detection/flutter_pitch_detection_platform_interface.dart';
import 'package:flutter_pitch_detection/flutter_pitch_detection_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterPitchDetectionPlatform with MockPlatformInterfaceMixin implements FlutterPitchDetectionPlatform {
  final StreamController<Map<String, dynamic>> _controller = StreamController.broadcast();
  int _sampleRate = 44100;
  int _bufferSize = 8192;
  double _accuracy = 0.8;
  bool _isRunning = false;

  // @override
  // Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Stream<Map<String, dynamic>> get onPitchDetected => _controller.stream;

  @override
  Future<void> setAccuracy(double accuracy) async {
    _accuracy = accuracy;
  }

  @override
  Future<void> setBufferSize(int bufferSize) async {
    _bufferSize = bufferSize;
  }

  @override
  Future<void> setSampleRate(int sampleRate) async {
    _sampleRate = sampleRate;
  }

  @override
  Future<void> startDetection({int sampleRate = 44100, int bufferSize = 8192, int overlap = 0}) async {
    _isRunning = true;
    _sampleRate = sampleRate;
    _bufferSize = bufferSize;

    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }
      _controller.add({
        'pitch': 440.0,
        'frequency': 440.0,
        'probability': _accuracy,
        'isPitched': true
      });
    });
  }

  @override
  Future<void> stopDetection() async {
    _isRunning = false;
  }

  @override
  Future<void> setParameters({int? sampleRate, int? bufferSize, double? accuracy}) async {
    if (sampleRate != null) _sampleRate = sampleRate;
    if (bufferSize != null) _bufferSize = bufferSize;
    if (accuracy != null) _accuracy = accuracy;
  }

  void simulatePitch(double pitch, double probability) {
    _controller.add({
      'pitch': pitch,
      'frequency': pitch,
      'probability': probability,
      'isPitched': probability > 0.8
    });
  }

  @override
  Future<double> getAccuracy() async {
    return _accuracy;
  }

  @override
  Future<int> getBufferSize() async {
    return _bufferSize;
  }

  @override
  Future<int> getSampleRate() async {
    return _sampleRate;
  }

  @override
  Future<bool> isRecording() async {
    return _isRunning;
  }

  @override
  Future<double> getFrequency() {
    // TODO: implement getFrequency
    throw UnimplementedError();
  }

  @override
  Future<String> getNote() {
    // TODO: implement getNote
    throw UnimplementedError();
  }

  @override
  Future<int> getOctave() {
    // TODO: implement getOctave
    throw UnimplementedError();
  }

  @override
  Future<String> printNoteOctave() {
    // TODO: implement printNoteOctave
    throw UnimplementedError();
  }

  @override
  Future<bool> requestMicrophonePermission() {
    // TODO: implement requestMicrophonePermission
    throw UnimplementedError();
  }

  @override
  Future<double> getDecibels() {
    // TODO: implement getDecibels
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelFlutterPitchDetection', () {
    const MethodChannel channel = MethodChannel('pitch_detection/methods');
    const EventChannel eventChannel = EventChannel('pitch_detection/events');

    late MethodChannelFlutterPitchDetection plugin;

    setUp(() {
      plugin = MethodChannelFlutterPitchDetection();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          // case 'getPlatformVersion':
          //   return 'Android 10';
          default:
            return null;
        }
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    // test('getPlatformVersion returns Android version', () async {
    //   expect(await plugin.getPlatformVersion(), 'Android 10');
    // });
  });

  group('FlutterPitchDetection', () {
    late MockFlutterPitchDetectionPlatform mockPlatform;

    setUp(() {
      mockPlatform = MockFlutterPitchDetectionPlatform();
      FlutterPitchDetectionPlatform.instance = mockPlatform;
    });

    // test('getPlatformVersion with mock', () async {
    //   final flutterPitchDetection = FlutterPitchDetection();
    //   expect(await flutterPitchDetection.getPlatformVersion(), '42');
    // });
  });
}
