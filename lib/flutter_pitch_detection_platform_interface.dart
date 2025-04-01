import 'flutter_pitch_detection.dart';

class FlutterPitchDetection {
  final FlutterPitchDetectionPlatform _platform;

  FlutterPitchDetection() : _platform = FlutterPitchDetectionPlatform.instance;

  Stream<Map<String, dynamic>> get onPitchDetected => _platform.onPitchDetected;

  Future<String?> getPlatformVersion() {
    return _platform.getPlatformVersion();
  }

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

  Future<void> setParameters({
    int? sampleRate,
    int? bufferSize,
    double? accuracy,
  }) async {
    return _platform.setParameters(sampleRate: sampleRate, bufferSize: bufferSize, accuracy: accuracy);
  }

  Future<void> setSampleRate(int sampleRate) async {
    return _platform.setSampleRate(sampleRate);
  }

  Future<void> setBufferSize(int bufferSize) async {
    return _platform.setBufferSize(bufferSize);
  }

  Future<void> setAccuracy(double accuracy) async {
    return _platform.setAccuracy(accuracy);
  }
}