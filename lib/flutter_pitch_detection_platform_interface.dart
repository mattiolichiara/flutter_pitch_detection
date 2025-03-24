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

  /// Starts the pitch detection service.
  ///
  /// Returns a success message if started successfully, or null if failed.
  Future<String?> startPitchDetection();

  /// Stops the pitch detection service.
  ///
  /// Returns a success message if stopped successfully, or null if failed.
  Future<String?> stopPitchDetection();

  /// Configures the pitch detection parameters.
  ///
  /// - [sampleRate]: The audio sample rate in Hz
  /// - [bufferSize]: The size of audio buffer
  /// - [accuracy]: The detection accuracy threshold
  ///
  /// Returns a success message if configured successfully, or null if failed.
  Future<String?> setParameters({
    required int sampleRate,
    required int bufferSize,
    required double accuracy,
  });

  /// A stream of pitch detection results.
  ///
  /// Each event contains a map with:
  /// - frequency: (double) detected frequency in Hz
  /// - note: (String) musical note name
  /// - octave: (int) musical octave
  /// - accuracy: (double) detection confidence (0.0 to 1.0)
  Stream<Map<String, dynamic>> get pitchStream;

  /// Checks if audio recording permission is granted.
  ///
  /// Returns true if granted, false if denied, and null if checking failed.
  Future<bool?> checkPermission();

  /// Requests audio recording permission.
  ///
  /// Returns true if granted, false if denied, and null if request failed.
  Future<bool?> requestPermission();

  /// Gets the native platform version string.
  Future<String?> getPlatformVersion();
}