import 'package:flutter/services.dart';
import 'flutter_pitch_detection.dart';

class MethodChannelFlutterPitchDetection extends FlutterPitchDetectionPlatform {
  static const MethodChannel _methodChannel =
  MethodChannel('pitch_detection/methods');

  static const EventChannel _eventChannel =
  EventChannel('pitch_detection/events');

  Stream<Map<String, dynamic>>? _pitchStream;

  @override
  Stream<Map<String, dynamic>> get onPitchDetected {
    _pitchStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event));
    return _pitchStream!;
  }

  @override
  Future<void> startDetection({
    int sampleRate = 44100,
    int bufferSize = 1024,
    int overlap = 0,
  }) async {
    try {
      await _methodChannel.invokeMethod('startDetection', {
        'sampleRate': sampleRate,
        'bufferSize': bufferSize,
        'overlap': overlap,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to start detection: ${e.message}');
    }
  }

  @override
  Future<void> stopDetection() async {
    try {
      await _methodChannel.invokeMethod('stopDetection');
    } on PlatformException catch (e) {
      throw Exception('Failed to stop detection: ${e.message}');
    }
  }
}