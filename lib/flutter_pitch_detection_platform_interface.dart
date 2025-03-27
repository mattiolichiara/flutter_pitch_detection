import 'flutter_pitch_detection.dart';

class FlutterPitchDetection {
  final FlutterPitchDetectionPlatform _platform;

  FlutterPitchDetection() : _platform = FlutterPitchDetectionPlatform.instance;

  Stream<Map<String, dynamic>> get onPitchDetected => _platform.onPitchDetected;

  Future<void> startDetection({
    int sampleRate = 44100,
    int bufferSize = 1024,
    int overlap = 0,
  }) async {
    return _platform.startDetection(
      sampleRate: sampleRate,
      bufferSize: bufferSize,
      overlap: overlap,
    );
  }

  Future<void> stopDetection() async {
    return _platform.stopDetection();
  }
}