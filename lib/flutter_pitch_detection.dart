import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<void> startDetection({int? sampleRate, int? bufferSize, int? overlap,}) async {
    try {
      await _instance.startDetection(sampleRate: sampleRate, bufferSize: bufferSize, overlap: overlap);
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        await openAppSettings();
      }
      rethrow;
    }
  }

  Future<void> stopDetection() async {
    await _instance.stopDetection();
  }

  // Future<String?> getPlatformVersion() {
  //   return FlutterPitchDetectionPlatform.instance.getPlatformVersion();
  // }

  Future<void> setParameters({
    int? sampleRate,
    int? bufferSize,
    double? toleranceCents,
    double? minPrecision,
  }) async {
    await FlutterPitchDetectionPlatform.instance.setParameters(
      sampleRate: sampleRate,
      bufferSize: bufferSize,
      toleranceCents: toleranceCents,
      minPrecision: minPrecision,
    );
  }

  Future<void> setSampleRate(int sampleRate) async {
    await FlutterPitchDetectionPlatform.instance.setSampleRate(sampleRate);
  }

  Future<void> setBufferSize(int bufferSize) async {
    await FlutterPitchDetectionPlatform.instance.setBufferSize(bufferSize);
  }

  Future<int> getSampleRate() async {
    return await FlutterPitchDetectionPlatform.instance.getSampleRate();
  }

  Future<int> getBufferSize() async {
    return await FlutterPitchDetectionPlatform.instance.getBufferSize();
  }

  Future<bool> isRecording() async {
    return await FlutterPitchDetectionPlatform.instance.isRecording();
  }

  Future<double> getFrequency() async {
    return await FlutterPitchDetectionPlatform.instance.getFrequency();
  }

  Future<String> getNote() async {
    return await FlutterPitchDetectionPlatform.instance.getNote();
  }

  Future<int> getOctave() async {
    return await FlutterPitchDetectionPlatform.instance.getOctave();
  }

  Future<String> printNoteOctave() async {
    return await FlutterPitchDetectionPlatform.instance.printNoteOctave();
  }

  Future<bool> isOnPitch(double toleranceCents, double minPrecision) async {
    return FlutterPitchDetectionPlatform.instance.isOnPitch(toleranceCents, minPrecision);
  }

  Future<int> getAccuracy(double toleranceCents) async {
    return FlutterPitchDetectionPlatform.instance.getAccuracy(toleranceCents);
  }

  Future<double> getMinPrecision() async {
    return FlutterPitchDetectionPlatform.instance.getMinPrecision();
  }

  Future<void> setMinPrecision(double minPrecision) async {
    return FlutterPitchDetectionPlatform.instance.setMinPrecision(minPrecision);
  }

  Future<double> getToleranceCents() async {
    return FlutterPitchDetectionPlatform.instance.getToleranceCents();
  }

  Future<void> setToleranceCents(double toleranceCents) async {
    return FlutterPitchDetectionPlatform.instance.setToleranceCents(toleranceCents);
  }

  Future<double> getVolume() async {
    return FlutterPitchDetectionPlatform.instance.getVolume();
  }

  Future<double> getVolumeFromDbFS() async {
    return FlutterPitchDetectionPlatform.instance.getVolumeFromDbFS();
  }
}