import 'dart:typed_data';

import 'flutter_pitch_detection_platform_interface.dart';

/// A Flutter plugin for real-time audio pitch detection.
///
/// Supports detection of musical notes, frequencies, and volume levels from microphone input.
///
///- Real-time pitch detection
///- Frequency, note name, octave and MIDI note detection
///- Raw audio data access (normalized and PCM formats)
///- Volume measurement (normalized and dBFS)
///- Pitch accuracy and probability
///- Configurable parameters (sample rate, buffer size, etc.)
///
class FlutterPitchDetection {
  final FlutterPitchDetectionPlatform _platform;

  FlutterPitchDetection() : _platform = FlutterPitchDetectionPlatform.instance;

  /// Stream of pitch detection results.
  ///
  /// Each event contains a map with:
  /// - `note` (String): Musical note (e.g., "C")
  /// - `octave` (int): Octave number
  /// - `noteOctave` (String): Combined note+octave (e.g., "C4")
  /// - `frequency` (double): Frequency in Hz
  /// - `midiNote` (int): MIDI note number
  /// - `volume` (double): Normalized volume (0.0-100.0)
  /// - `volumeDbFS` (double): Volume in dBFS (0.0-100.0)
  /// - `accuracy` (int): Detection confidence (0-100)
  /// - `isOnPitch` (bool): True if within tolerance
  /// - `toleranceCents` (double): Current pitch tolerance (0.0 to 0.1)
  /// - `bufferSize` (int): Current buffer size (default: 8196, min: 7056)
  /// - `sampleRate` (int): Audio sampling rate (defaults to 44100)
  /// - `minPrecision` (double): Current pitch confidence (0.0 to 0.1)
  /// - `pcmData` (Uint8List): Raw PCM byte data.
  /// - `streamData` (List`<`double`>`): Processed audio data (normalized doubles)
  Stream<Map<String, dynamic>> get onPitchDetected {
    return _platform.onPitchDetected;
  }

  /// Starts audio processing and begins pitch detection.
  ///
  /// Throws a [PlatformException] if:
  /// - Microphone permission is denied
  /// - Audio capture fails to start
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

  /// Stops pitch detection and releases audio resources.
  Future<void> stopDetection() async {
    return _platform.stopDetection();
  }

  /// Configures audio processing parameters.
  ///
  /// - [sampleRate]: Audio sample rate in Hz (default: 44100)
  /// - [bufferSize]: FFT buffer size (default: 8196, min: 7056)
  /// - [toleranceCents]: Pitch tolerance in cents (0.0 to 1.0)
  /// - [minPrecision]: Minimum confidence threshold (0.0 to 1.0)
  Future<void> setParameters({
    int? sampleRate,
    int? bufferSize,
    double? toleranceCents,
    double? minPrecision,
  }) async {
    return _platform.setParameters(
      sampleRate: sampleRate,
      bufferSize: bufferSize,
      toleranceCents: toleranceCents,
      minPrecision: minPrecision,
    );
  }

  ///Sets audio sample rate (e.g., 44100).
  Future<void> setSampleRate(int sampleRate) async {
    return _platform.setSampleRate(sampleRate);
  }

  ///Sets buffer size (default: 8196, min: 7056).
  Future<void> setBufferSize(int bufferSize) async {
    return _platform.setBufferSize(bufferSize);
  }

  ///Returns current sample rate.
  Future<int> getSampleRate() async {
    return _platform.getSampleRate();
  }

  ///Returns current buffer size.
  Future<int> getBufferSize() async {
    return _platform.getBufferSize();
  }

  ///Checks if detection is currently running.
  Future<bool> isRecording() async {
    return _platform.isRecording();
  }

  ///Returns current detected frequency (Hz).
  Future<double> getFrequency() async {
    return _platform.getFrequency();
  }

  ///Returns musical note (e.g., "C").
  Future<String> getNote() async {
    return _platform.getNote();
  }

  ///Returns current MIDI note number. (0-127)
  Future<int> getMidiNote() async {
    return _platform.getMidiNote();
  }

  ///Returns note octave (e.g., 4).
  Future<int> getOctave() async {
    return _platform.getOctave();
  }

  ///Logs note+octave (e.g., "C4").
  Future<String> printNoteOctave() async {
    return _platform.printNoteOctave();
  }

  ///Returns bool if pitch meets precision.
  Future<bool> isOnPitch(double toleranceCents, double minPrecision) async {
    return _platform.isOnPitch(toleranceCents, minPrecision);
  }

  ///Returns pitch confidence in % (0 to 100).
  Future<int> getAccuracy(double toleranceCents) async {
    return _platform.getAccuracy(toleranceCents);
  }

  ///Returns the pitch deviation in cents (-50 to +50).
  ///- Negative values mean the note is lower than target
  ///- 0 means perfectly in tune
  ///- Positive values mean the note is higher than target
  ///
  ///Returns 0 if no valid frequency is detected
  Future<double> getPitchDeviation() async {
    return _platform.getPitchDeviation();
  }

  ///Returns current precision(0.0 to 1.0)
  Future<double> getMinPrecision() async {
    return _platform.getMinPrecision();
  }

  ///Sets minimum pitch confidence threshold (0.0 to 1.0).
  Future<void> setMinPrecision(double minPrecision) async {
    return _platform.setMinPrecision(minPrecision);
  }

  ///Returns current tolerance (0.0 to 1.0).
  Future<double> getToleranceCents() async {
    return _platform.getToleranceCents();
  }

  ///Sets pitch tolerance in cents (0.0 to 1.0).
  Future<void> setToleranceCents(double toleranceCents) async {
    return _platform.setToleranceCents(toleranceCents);
  }

  ///Returns normalized volume (0.0 to 100.0).
  Future<double> getVolume() async {
    return _platform.getVolume();
  }

  ///Returns volume in dBFS (0.0 to 100.0).
  Future<double> getVolumeFromDbFS() async {
    return _platform.getVolumeFromDbFS();
  }

  ///Gets processed audio data (normalized doubles).
  Future<List<double>> getRawDataFromStream() {
    return _platform.getRawDataFromStream();
  }

  /// Gets raw PCM audio data from the current buffer.
  ///
  /// Returns [Uint8List] of 16-bit PCM samples.
  Future<Uint8List> getRawPcmDataFromStream() {
    return _platform.getRawPcmDataFromStream();
  }
}
