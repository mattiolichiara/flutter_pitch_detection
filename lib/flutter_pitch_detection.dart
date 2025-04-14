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

  Future<bool> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;

    if (status.isGranted) {
      return true;
    } else if (status.isDenied || status.isRestricted || status.isLimited) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  Future<void> startDetection({
    int? sampleRate,
    int? bufferSize,
    int? overlap,
  }) async {
    final hasPermission = await _instance.requestMicrophonePermission();
    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }

    await _instance.startDetection(
      sampleRate: sampleRate,
      bufferSize: bufferSize,
      overlap: overlap,
    );
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
    double? accuracy,
  }) async {
    await FlutterPitchDetectionPlatform.instance.setParameters(
      sampleRate: sampleRate,
      bufferSize: bufferSize,
      accuracy: accuracy,
    );
  }

  Future<void> setSampleRate(int sampleRate) async {
    await FlutterPitchDetectionPlatform.instance.setSampleRate(sampleRate);
  }

  Future<void> setBufferSize(int bufferSize) async {
    await FlutterPitchDetectionPlatform.instance.setBufferSize(bufferSize);
  }

  Future<void> setAccuracy(double accuracy) async {
    await FlutterPitchDetectionPlatform.instance.setAccuracy(accuracy);
  }

  Future<int> getSampleRate() async {
    return await FlutterPitchDetectionPlatform.instance.getSampleRate();
  }

  Future<int> getBufferSize() async {
    return await FlutterPitchDetectionPlatform.instance.getBufferSize();
  }

  Future<double> getAccuracy() async {
    return await FlutterPitchDetectionPlatform.instance.getAccuracy();
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
}