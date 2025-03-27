import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_pitch_detection_method_channel.dart';

abstract class FlutterPitchDetectionPlatform extends PlatformInterface {
  FlutterPitchDetectionPlatform() : super(token: _token);
  static final Object _token = Object();

  static FlutterPitchDetectionPlatform _instance = MethodChannelFlutterPitchDetection();

  static FlutterPitchDetectionPlatform get instance => _instance;

  static set instance(FlutterPitchDetectionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<Map<String, dynamic>> get onPitchDetected;

  Future<void> startDetection({
    int sampleRate = 44100,
    int bufferSize = 1024,
    int overlap = 0,
  });

  Future<void> stopDetection();
}