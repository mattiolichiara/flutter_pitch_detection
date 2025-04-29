import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_pitch_detection_method_channel.dart';

abstract class FlutterPitchDetectionPlatform extends PlatformInterface {
  FlutterPitchDetectionPlatform() : super(token: _token);
  static final Object _token = Object();

  static FlutterPitchDetectionPlatform _instance =
      MethodChannelFlutterPitchDetection();

  static FlutterPitchDetectionPlatform get instance => _instance;

  static set instance(FlutterPitchDetectionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<Map<String, dynamic>> get onPitchDetected;
  Future<void> startDetection({int? sampleRate, int? bufferSize, int? overlap});
  Future<void> stopDetection();

  Future<void> setParameters({
    int? sampleRate,
    int? bufferSize,
    double? toleranceCents,
    double? minPrecision,
  });
  Future<void> setSampleRate(int sampleRate);
  Future<void> setBufferSize(int bufferSize);
  Future<void> setMinPrecision(double minPrecision);
  Future<void> setToleranceCents(double toleranceCents);
  Future<int> getSampleRate();
  Future<int> getBufferSize();
  Future<double> getMinPrecision();
  Future<double> getToleranceCents();

  Future<bool> isRecording();
  Future<double> getFrequency();
  Future<String> getNote();
  Future<int> getMidiNote();
  Future<int> getOctave();
  Future<String> printNoteOctave();
  Future<bool> isOnPitch(double toleranceCents, double minPrecision);
  Future<int> getAccuracy(double toleranceCents);
  Future<double> getPitchDeviation();
  Future<double> getVolume();
  Future<double> getVolumeFromDbFS();

  Future<List<double>> getRawDataFromStream();
  Future<Uint8List> getRawPcmDataFromStream();
}
