import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'flutter_pitch_detection_platform_interface.dart';

/// A plugin for real-time audio pitch detection
class FlutterPitchDetection {
  static const MethodChannel _channel = MethodChannel('flutter_pitch_detection');

  /// Starts pitch detection
  /// Returns success message or null if failed
  static Future<String?> startPitchDetection() async {
    try {
      return await FlutterPitchDetectionPlatform.instance.startPitchDetection();
    } catch (e) {
      debugPrint('Error starting pitch detection: $e');
      return null;
    }
  }

  /// Stops pitch detection
  /// Returns success message or null if failed
  static Future<String?> stopPitchDetection() async {
    try {
      return await FlutterPitchDetectionPlatform.instance.stopPitchDetection();
    } catch (e) {
      debugPrint('Error stopping pitch detection: $e');
      return null;
    }
  }

  /// Configures detection parameters
  static Future<String?> setParameters({
    required int sampleRate,
    required int bufferSize,
    required double accuracy,
  }) async {
    try {
      return await FlutterPitchDetectionPlatform.instance.setParameters(
        sampleRate: sampleRate,
        bufferSize: bufferSize,
        accuracy: accuracy,
      );
    } catch (e) {
      debugPrint('Error setting parameters: $e');
      return null;
    }
  }

  /// Stream of pitch detection results
  static Stream<Map<String, dynamic>> get pitchStream {
    return FlutterPitchDetectionPlatform.instance.pitchStream.handleError((e) {
      debugPrint('Pitch stream error: $e');
      return {'error': e.toString()};
    });
  }

  /// Checks if audio recording permission is granted
  static Future<bool> checkPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkPermission');
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking permission: $e');
      return false;
    }
  }

  /// Requests audio recording permission
  static Future<bool> requestPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPermission');
      return result ?? false;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  /// Gets the native platform version
  static Future<String?> getPlatformVersion() async {
    try {
      return await FlutterPitchDetectionPlatform.instance.getPlatformVersion();
    } catch (e) {
      debugPrint('Error getting platform version: $e');
      return null;
    }
  }
}