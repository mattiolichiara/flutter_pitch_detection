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

  // @override
  // Future<String?> getPlatformVersion() async {
  //   final version = await _methodChannel.invokeMethod<String>('getPlatformVersion');
  //   return version;
  // }

  @override
  Future<void> setParameters({
    int? sampleRate,
    int? bufferSize,
    double? accuracy,
  }) async {
    try {
      await _methodChannel.invokeMethod('setParameters', {
        if (sampleRate != null) 'sampleRate': sampleRate,
        if (bufferSize != null) 'bufferSize': bufferSize,
        if (accuracy != null) 'accuracy': accuracy,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to set parameters: ${e.message}');
    }
  }

  @override
  Future<void> setSampleRate(int sampleRate) async {
    try {
      await _methodChannel.invokeMethod('setSampleRate', {
        'sampleRate': sampleRate,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to set sample rate: ${e.message}');
    }
  }

  @override
  Future<void> setBufferSize(int bufferSize) async {
    try {
      await _methodChannel.invokeMethod('setBufferSize', {
        'bufferSize': bufferSize,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to set buffer size: ${e.message}');
    }
  }

  @override
  Future<void> setAccuracy(double accuracy) async {
    try {
      await _methodChannel.invokeMethod('setAccuracy', {
        'accuracy': accuracy,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to set accuracy: ${e.message}');
    }
  }
}