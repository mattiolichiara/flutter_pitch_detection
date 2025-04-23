# Flutter Pitch Detection Plugin

A Flutter plugin for real-time audio pitch detection using TarsosDSP on Android.

## Features

- Real-time pitch detection
- Frequency, note name, and octave detection
- Volume measurement (normalized and dBFS)
- Pitch accuracy and probability
- Configurable parameters (sample rate, buffer size, etc.)
<br>
<img src="https://github.com/user-attachments/assets/7f230f00-615b-4e19-a508-b39851eed765" width="200">
<img src="https://github.com/user-attachments/assets/a7d3b6db-f199-4525-a2b4-ebc96d9e9b6d" width="200">
<img src="https://github.com/user-attachments/assets/9f5323d8-435a-41e6-a3d8-646882832a10" width="200">
<img src="https://github.com/user-attachments/assets/d711b1a2-4546-41ab-9588-e7bdaf6419d0" width="200"><br><br>

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_pitch_detection: ^x.x.x
```

Then import:

```dart
import 'package:flutter_pitch_detection/flutter_pitch_detection.dart';
```

## Quick Start

**Initialize the detector**
```dart
final pitchDetector = FlutterPitchDetection(); 
```

**Set Parameters (Optional but recommended)** 
<br><br>
Set individual parameters:
```dart
pitchDetector.setSampleRate(44100);  
pitchDetector.setBufferSize(8192);   
pitchDetector.setMinPrecision(0.8);
```

Or set multiple parameters at once:
```dart
pitchDetector.setParameters(toleranceCents: 0.6, bufferSize: 8192, sampleRate: 44100, minPrecision: 0.7);
```

**Start Detection**
```dart
await pitchDetector.startDetection();
```

**Retrieve Recording Status**
```dart
await pitchDetector.isRecording();
```

**Listen to Real-Time Updates**
```dart
StreamSubscription<Map<String, dynamic>>? _pitchSubscription;

_pitchSubscription = FlutterPitchDetectionPlatform.instance.onPitchDetected.listen((event) async {
    await pitchDetector.getNote();
    await pitchDetector.getFrequency();
    await pitchDetector.printNoteOctave();
    await pitchDetector.getOctave();
    await pitchDetector.getToleranceCents();
    await pitchDetector.getBufferSize();
    await pitchDetector.getSampleRate();
    await pitchDetector.isRecording();
    await pitchDetector.getMinPrecision();
    await pitchDetector.getAccuracy(toleranceCents);
    await pitchDetector.isOnPitch(toleranceCents, minPrecision);
    await pitchDetector.getVolume();
    await pitchDetector.getVolumeFromDbFS();
});    
```

**Stop Detection**
```dart
await pitchDetector.stopDetection();
_pitchSubscription?.cancel();
```

## Method Reference

**Core Methods** <br>
- `startDetection({int? sampleRate, int? bufferSize, int? overlap,})`	Starts real-time pitch detection. Callback returns (frequency, note, octave, accuracy, volume). <br>
- `stopDetection()`	Stops the detection. <br><br>

**Configuration (Call before startDetection)** <br>
- `setSampleRate(int rate)`	Sets audio sample rate (e.g., 44100). <br>
- `setBufferSize(int size)`	Sets buffer size (min 7056). <br>
- `setMinPrecision(double precision)`	Sets minimum pitch confidence threshold (0.0 to 1.0). <br>
- `setToleranceCents(int cents)`	Sets pitch tolerance in cents (0.0 to 1.0). <br>

- `getSampleRate()`	Returns current sample rate. <br>
- `getBufferSize()`	Returns current buffer size. <br>
- `getMinPrecision()`	Returns current min precision. <br>
- `getToleranceCents()`	Returns current tolerance. <br><br>

**Real-Time Data** <br>
- `onPitchDetected` A real-time event stream that provides continuous pitch detection updates. Subscribe to this stream to receive live audio analysis data, including frequency, note, volume, and accuracy metrics. <br><br>
- `getFrequency()`	Returns current detected frequency (Hz). <br>
- `getNote()`	Returns musical note (e.g., "C"). <br>
- `getOctave()`	Returns note octave (e.g., 4). <br>
- `printNoteOctave()`	Logs note+octave (e.g., "C4"). <br>
- `isOnPitch()`	Returns bool if pitch meets precision. <br>
- `getAccuracy()`	Returns pitch confidence in % (0 to 100). <br>
- `getVolume()`	Returns normalized volume (0.0 to 100.0). <br>
- `getVolumeFromDbFS()`	Returns volume in dBFS (0.0 to 100.0). <br>
- `isRecording()`	Returns bool if detection is active. <br>

## Important Notes

- **Android-only:** This plugin does not support iOS **yet**. <br>
- **Parameter Order:** Set configs (`setSampleRate`, `setBufferSize`, etc.) **before** `startDetection`. <br>
- **Permissions:** Mic permissions are **automatically handled** on Android. <br>

## Example App

Check the [example/](https://github.com/mattiolichiara/flutter_pitch_detection/tree/main/example) folder for a complete demo app.

## License

[MIT](https://github.com/mattiolichiara/flutter_pitch_detection/blob/main/LICENSE) 
