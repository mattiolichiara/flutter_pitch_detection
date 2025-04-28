import 'package:flutter/services.dart';
import 'flutter_pitch_detection_platform_interface.dart';

class MethodChannelFlutterPitchDetection extends FlutterPitchDetectionPlatform {
  static const MethodChannel _methodChannel =
  MethodChannel('pitch_detection/methods');

  static const EventChannel _eventChannel =
  EventChannel('pitch_detection/events');

  Stream<Map<String, dynamic>>? _pitchStream;

  @override
  Stream<Map<String, dynamic>> get onPitchDetected {
    _pitchStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event));
    return _pitchStream!;
  }

  @override
  Future<void> startDetection({
    int? sampleRate,
    int? bufferSize,
    int? overlap,
  }) async {
    try {
      await _methodChannel.invokeMethod('startDetection', {
        'sampleRate': sampleRate,
        'bufferSize': bufferSize,
        'overlap': overlap,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to start detection: ${e.message}');
    }
  }

  @override
  Future<void> stopDetection() async {
    try {
      await _methodChannel.invokeMethod('stopDetection');
    } on PlatformException catch (e) {
      throw Exception('Failed to stop detection: ${e.message}');
    }
  }

  @override
  Future<void> setParameters({
    int? sampleRate,
    int? bufferSize,
    double? toleranceCents,
    double? minPrecision,
  }) async {
    try {
      await _methodChannel.invokeMethod('setParameters', {
        if (sampleRate != null) 'sampleRate': sampleRate,
        if (bufferSize != null) 'bufferSize': bufferSize,
        if (toleranceCents != null) 'toleranceCents': toleranceCents,
        if (minPrecision != null) 'minPrecision': minPrecision,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to set parameters: ${e.message}');
    }
  }

  @override
  Future<void> setSampleRate(int sampleRate) async {
    try {
      await _methodChannel.invokeMethod('setSampleRate', {
        'sampleRate': sampleRate,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to set sample rate: ${e.message}');
    }
  }

  @override
  Future<void> setBufferSize(int bufferSize) async {
    try {
      await _methodChannel.invokeMethod('setBufferSize', {
        'bufferSize': bufferSize,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to set buffer size: ${e.message}');
    }
  }
  
  @override
  Future<int> getSampleRate() async {
    try {
      return await _methodChannel.invokeMethod('getSampleRate');
    } on PlatformException catch(e) {
      throw Exception("Sample Rate Read Error: ${e.message}");
    }
  }

  @override
  Future<int> getBufferSize() async {
    try {
      return await _methodChannel.invokeMethod('getBufferSize');
    } on PlatformException catch(e) {
      throw Exception("Buffer Size Read Error: ${e.message}");
    }
  }

  @override
  Future<bool> isRecording() async {
    try {
      return await _methodChannel.invokeMethod('isRecording');
    } on PlatformException catch(e) {
      throw Exception("Error Retrieving Recording Status: ${e.message}");
    }
  }

  @override
  Future<double> getFrequency() async {
    try {
      return await _methodChannel.invokeMethod('getFrequency');
    } on PlatformException catch(e) {
      throw Exception("Error Retrieving Frequency: ${e.message}");
    }
  }

  @override
  Future<String> getNote() async {
    try {
      final result = await _methodChannel.invokeMethod('getNote');
      return result ?? "";
    } on PlatformException catch(e) {
      throw Exception("Error Retrieving Current Note: ${e.message}");
    }
  }

  @override
  Future<int> getMidiNote() async {
    try {
      final result = await _methodChannel.invokeMethod('getMidiNote');
      return result ?? 0;
    } on PlatformException catch(e) {
      throw Exception("Error Retrieving Current MIDI Note: ${e.message}");
    }
  }

  @override
  Future<int> getOctave() async {
    try {
      return await _methodChannel.invokeMethod('getOctave');
    } on PlatformException catch(e) {
      throw Exception("Error Retrieving Octave: ${e.message}");
    }
  }

  @override
  Future<String> printNoteOctave() async {
    try {
      return await _methodChannel.invokeMethod('printNoteOctave');
    } on PlatformException catch(e) {
      throw Exception("Error Retrieving Note-Octave Full Value: ${e.message}");
    }
  }

  @override
  Future<bool> isOnPitch(double toleranceCents, double minPrecision) async {
    try {
      return await _methodChannel.invokeMethod('isOnPitch', {'toleranceCents': toleranceCents, 'minPrecision': minPrecision},);
    } on PlatformException catch (e) {
      throw Exception("Failed to check pitch: ${e.message}");
    }
  }

  @override
  Future<int> getAccuracy(double toleranceCents) async {
    try {
      final result = await _methodChannel.invokeMethod<int>('getAccuracy', {
        'toleranceCents': toleranceCents,
      });
      return result ?? 0;
    } on PlatformException catch (e) {
      throw Exception("Failed to get accuracy: ${e.message}");
    }
  }

  @override
  Future<void> setMinPrecision(double minPrecision) async {
    try {
      await _methodChannel.invokeMethod('setMinPrecision', {
        'setMinPrecision': minPrecision,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to set min precision: ${e.message}');
    }
  }

  @override
  Future<double> getMinPrecision() async {
    try {
      return await _methodChannel.invokeMethod('getMinPrecision');
    } on PlatformException catch(e) {
      throw Exception("Error Retrieving Min Precision Value: ${e.message}");
    }
  }

  @override
  Future<double> getToleranceCents() async {
    try {
      return await _methodChannel.invokeMethod('getToleranceCents');
    } on PlatformException catch(e) {
      throw Exception("Tolerance Hz Read Error: ${e.message}");
    }
  }

  @override
  Future<void> setToleranceCents(double toleranceCents) async {
    try {
      await _methodChannel.invokeMethod('setToleranceCents', {
        'toleranceCents': toleranceCents,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to set toleranceCents: ${e.message}');
    }
  }

  @override
  Future<double> getVolume() async {
    try {
      return await _methodChannel.invokeMethod('getVolume');
    } on PlatformException catch(e) {
      throw Exception("Volume Read Error: ${e.message}");
    }
  }

  @override
  Future<double> getVolumeFromDbFS() async {
    try {
      return await _methodChannel.invokeMethod('getVolumeFromDbFS');
    } on PlatformException catch(e) {
      throw Exception("Volume from DbFS Read Error: ${e.message}");
    }
  }

  @override
  Future<List<double>> getRawDataFromStream() async {
    try {
      final result = await _methodChannel.invokeMethod<List<dynamic>>('getRawDataFromStream');
      return result?.map((e) => (e as num).toDouble()).toList() ?? <double>[];
    } on PlatformException catch(e) {
      throw Exception("Raw Stream Data Read Error: ${e.message}");
    }
  }

  @override
  Future<Uint8List> getRawPcmDataFromStream() async {
    try {
      return await _methodChannel.invokeMethod('getRawPcmDataFromStream');
    } on PlatformException catch(e) {
      throw Exception("PCM Stream Data Read Error: ${e.message}");
    }
  }
}