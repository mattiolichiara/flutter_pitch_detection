import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'flutter_pitch_detection_platform_interface.dart';

/// The method channel implementation of [FlutterPitchDetectionPlatform].
class MethodChannelFlutterPitchDetection extends FlutterPitchDetectionPlatform {

  final MethodChannel _methodChannel = const MethodChannel('flutter_pitch_detection');

  static const EventChannel _eventChannel = EventChannel('flutter_pitch_detection_stream');

  @override
  Future<String?> startPitchDetection() async {
    try {
      return await _methodChannel.invokeMethod<String>('startPitchDetection');
    } on PlatformException catch (e) {
      debugPrint('Failed to start pitch detection: ${e.message}');
      return null;
    }
  }

  @override
  Future<String?> stopPitchDetection() async {
    try {
      return await _methodChannel.invokeMethod<String>('stopPitchDetection');
    } on PlatformException catch (e) {
      debugPrint('Failed to stop pitch detection: ${e.message}');
      return null;
    }
  }

  @override
  Future<String?> setParameters({
    required int sampleRate,
    required int bufferSize,
    required double accuracy,
  }) async {
    try {
      return await _methodChannel.invokeMethod<String>('setParameters', {
        'sampleRate': sampleRate,
        'bufferSize': bufferSize,
        'accuracy': accuracy,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to set parameters: ${e.message}');
      return null;
    }
  }

  @override
  Stream<Map<String, dynamic>> get pitchStream {
    return _eventChannel.receiveBroadcastStream().handleError(
          (error) {
        debugPrint('Pitch stream error: $error');
      },
      test: (error) => error is PlatformException,
    ).map<Map<String, dynamic>>((data) {
      if (data is Map) {
        try {
          return Map<String, dynamic>.from(data);
        } catch (e) {
          debugPrint('Failed to parse pitch data: $e');
          return {'error': 'Invalid data format'};
        }
      }
      return {'error': 'Unexpected data type'};
    });
  }

  @override
  Future<String?> getPlatformVersion() async {
    try {
      return await _methodChannel.invokeMethod<String>('getPlatformVersion');
    } on PlatformException catch (e) {
      debugPrint('Failed to get platform version: ${e.message}');
      return null;
    }
  }

  @override
  Future<bool?> checkPermission() async {
    try {
      return await _methodChannel.invokeMethod<bool>('checkPermission');
    } on PlatformException catch (e) {
      debugPrint('Failed to check permission: ${e.message}');
      return null;
    }
  }

  @override
  Future<bool?> requestPermission() async {
    try {
      return await _methodChannel.invokeMethod<bool>('requestPermission');
    } on PlatformException catch (e) {
      debugPrint('Failed to request permission: ${e.message}');
      return null;
    }
  }
}