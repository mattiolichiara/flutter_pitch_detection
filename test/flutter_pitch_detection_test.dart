import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pitch_detection/flutter_pitch_detection.dart';
import 'package:flutter_pitch_detection/flutter_pitch_detection_platform_interface.dart';
import 'package:flutter_pitch_detection/flutter_pitch_detection_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterPitchDetectionPlatform
    with MockPlatformInterfaceMixin
    implements FlutterPitchDetectionPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  // TODO: implement pitchStream
  Stream<Map<String, dynamic>> get pitchStream => throw UnimplementedError();

  @override
  Future<String?> setParameters({required int sampleRate, required int bufferSize, required double accuracy}) {
    // TODO: implement setParameters
    throw UnimplementedError();
  }

  @override
  Future<String?> startPitchDetection() {
    // TODO: implement startPitchDetection
    throw UnimplementedError();
  }

  @override
  Future<String?> stopPitchDetection() {
    // TODO: implement stopPitchDetection
    throw UnimplementedError();
  }

  @override
  Future<bool?> checkPermission() {
    // TODO: implement checkPermission
    throw UnimplementedError();
  }

  @override
  Future<bool?> requestPermission() {
    // TODO: implement requestPermission
    throw UnimplementedError();
  }
}

void main() {
  final FlutterPitchDetectionPlatform initialPlatform = FlutterPitchDetectionPlatform.instance;

  test('$MethodChannelFlutterPitchDetection is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterPitchDetection>());
  });

  test('getPlatformVersion', () async {
    FlutterPitchDetection flutterPitchDetectionPlugin = FlutterPitchDetection();
    MockFlutterPitchDetectionPlatform fakePlatform = MockFlutterPitchDetectionPlatform();
    FlutterPitchDetectionPlatform.instance = fakePlatform;

    expect(await FlutterPitchDetection.getPlatformVersion(), '42');
  });
}
