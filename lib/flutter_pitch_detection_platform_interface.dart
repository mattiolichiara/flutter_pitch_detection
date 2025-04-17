import 'flutter_pitch_detection.dart';

class FlutterPitchDetection {
  final FlutterPitchDetectionPlatform _platform;

  FlutterPitchDetection() : _platform = FlutterPitchDetectionPlatform.instance;

  Stream<Map<String, dynamic>> get onPitchDetected => _platform.onPitchDetected;

  // Future<String?> getPlatformVersion() {
  //   return _platform.getPlatformVersion();
  // }

  Future<void> startDetection({
    int? sampleRate,
    int? bufferSize,
    int? overlap,
  }) async {
    return _platform.startDetection(
      sampleRate: sampleRate ?? 44100,
      bufferSize: bufferSize ?? 8192,
      overlap: overlap ?? 0,
    );
  }

  Future<void> stopDetection() async {
    return _platform.stopDetection();
  }

  Future<void> setParameters({
    int? sampleRate,
    int? bufferSize,
    double? toleranceCents,
    double? minPrecision,
  }) async {
    return _platform.setParameters(sampleRate: sampleRate, bufferSize: bufferSize, toleranceCents: toleranceCents, minPrecision: minPrecision);
  }

  Future<void> setSampleRate(int sampleRate) async {
    return _platform.setSampleRate(sampleRate);
  }

  Future<void> setBufferSize(int bufferSize) async {
    return _platform.setBufferSize(bufferSize);
  }

  Future<int> getSampleRate() async {
    return _platform.getSampleRate();
  }

  Future<int> getBufferSize() async {
    return _platform.getBufferSize();
  }

  Future<bool> isRecording() async {
    return _platform.isRecording();
  }

  Future<double> getFrequency() async {
    return _platform.getFrequency();
  }

  Future<String> getNote() async {
    return _platform.getNote();
  }

  Future<int> getOctave() async {
    return _platform.getOctave();
  }

  Future<String> printNoteOctave() async {
    return _platform.printNoteOctave();
  }

  Future<bool> isOnPitch(double toleranceCents, double minPrecision) async {
    return _platform.isOnPitch(toleranceCents, minPrecision);
  }

  Future<int> getAccuracy(double toleranceCents) async {
    return _platform.getAccuracy(toleranceCents);
  }

  Future<double> getMinPrecision() async {
    return _platform.getMinPrecision();
  }

  Future<void> setMinPrecision(double minPrecision) async {
    return _platform.setMinPrecision(minPrecision);
  }

  Future<double> getToleranceCents() async {
    return _platform.getToleranceCents();
  }

  Future<void> setToleranceCents(double toleranceCents) async {
    return _platform.setToleranceCents(toleranceCents);
  }

  Future<double> getVolume() async {
    return _platform.getVolume();
  }

  Future<double> getVolumeFromDbFS() async {
    return _platform.getVolumeFromDbFS();
  }
}