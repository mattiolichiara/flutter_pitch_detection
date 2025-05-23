# Flutter Pitch Detection Plugin

A Flutter plugin for real-time pitch detection using TarsosDSP on Android.

## Features

- Real-time pitch detection
- Frequency, note name, octave and MIDI note detection
- Supports different A4 reference frequencies
- Raw audio data access (normalized and PCM formats)
- Volume measurement (normalized and dBFS)
- Pitch accuracy and Pitch Deviation
- Configurable parameters (sample rate, buffer size, etc.)
  <br><br>

<img src="https://github.com/user-attachments/assets/3750aabf-b8d6-4369-8da1-2a7af50fb1b3" width="200">
<img src="https://github.com/user-attachments/assets/59e50f65-61df-4114-a49c-819e054f4008" width="200">
<img src="https://github.com/user-attachments/assets/d51b1dcb-346b-4b5b-8c24-0c709b9188d8" width="200"> <br><br>


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
pitchDetector.setToleranceCents(0.6);
pitchDetector.setA4Reference(440.0);
```

Or set multiple parameters at once:
```dart
pitchDetector.setParameters(toleranceCents: 0.6, bufferSize: 8192, sampleRate: 44100, minPrecision: 0.7, a4Reference: 440.0);
```

**Start Detection**
```dart
StreamSubscription<Map<String, dynamic>>? _pitchSubscription;

await pitchDetector.startDetection();
```

**Retrieve Recording Status**
```dart
await pitchDetector.isRecording();
```

**Listen to Real-Time Updates**
```dart
StreamSubscription<Map<String, dynamic>>? _pitchSubscription;

_pitchSubscription = pitchDetector.onPitchDetected.listen((data) async {
    await pitchDetector.printNoteOctave();
    await pitchDetector.getNote();
    await pitchDetector.getOctave();
    await pitchDetector.getMidiNote();
    await pitchDetector.getFrequency();
    
    await pitchDetector.getAccuracy(toleranceCents);
    await pitchDetector.getPitchDeviation();
    await pitchDetector.isOnPitch(toleranceCents, minPrecision);
    await pitchDetector.getVolume();
    await pitchDetector.getVolumeFromDbFS();
    
    await pitchDetector.getToleranceCents();
    await pitchDetector.getBufferSize();
    await pitchDetector.getSampleRate();
    await pitchDetector.getMinPrecision();
    await pitchDetector.getA4Reference();
    
    await _pitchDetection.getRawPcmDataFromStream();
    await _pitchDetection.getRawDataFromStream();
});    
```
Or
```dart
StreamSubscription<Map<String, dynamic>>? _pitchSubscription;

_pitchSubscription = pitchDetector.onPitchDetected.listen((data) async {
    data['noteOctave'] ?? "";
    data['note'] ?? "";
    data['octave'] ?? -1;
    data['midiNote'] ?? -1;
    data['frequency'] ?? 0;
    
    data['accuracy'] ?? 0;
    data['pitchDeviation'] ?? 0;
    data['isOnPitch'] ?? false;
    data['volume'] ?? 0;
    data['volumeDbFS'] ?? 0;
    
    data['toleranceCents'] ?? defaultTolerance;
    data['bufferSize'] ?? defaultBufferSize;
    data['sampleRate'] ?? defaultSampleRate;
    data['minPrecision'] ?? defaultPrecision;
    data['a4Reference'] ?? defaultA4Reference;
    
    data['pcmData'] ?? Uint8List(0);
    data['streamData'] ?? [];
});
```

**Stop Detection**
```dart
await _pitchSubscription?.cancel();
_pitchSubscription = null;

await pitchDetector.stopDetection();
```

## Method Reference

**Core Methods** <br>
- `startDetection({int? sampleRate, int? bufferSize, int? overlap,})`	Starts real-time pitch detection. Callback returns (frequency, note, octave, accuracy, volume, etc.). <br>
- `stopDetection()`	Stops the detection. <br><br>

**Configuration** <br>
- `setSampleRate(int rate)`	Sets audio sample rate (e.g., 44100). <br>
- `setBufferSize(int size)`	Sets buffer size (min 7056). <br>
- `setMinPrecision(double precision)`	Sets minimum pitch confidence threshold (0.0 to 1.0). <br>
- `setToleranceCents(int cents)`	Sets pitch tolerance in cents (0.0 to 1.0). <br>
- `setA4Reference(double a4Reference)`	Sets the reference frequency for A4 in Hertz (defaults to 440.0). <br>

- `getSampleRate()`	Returns current sample rate. <br>
- `getBufferSize()`	Returns current buffer size. <br>
- `getMinPrecision()`	Returns current min precision. <br>
- `getToleranceCents()`	Returns current tolerance. <br>
- `getA4Reference()`	Returns current reference frequency for A4 in Hertz. <br><br>

**Real-Time Data** <br>
- `onPitchDetected` A real-time event stream that provides continuous pitch detection updates. Subscribe to this stream to receive live audio analysis data, including frequency, note, volume, and accuracy metrics. <br><br>
- `getFrequency()`	Returns current detected frequency (Hz). <br>
- `getNote()`	Returns musical note (e.g., "C"). <br>
- `getMidiNote()` Returns current MIDI note number. (0-127) <br>
- `getOctave()`	Returns note octave (e.g., 4). <br>
- `printNoteOctave()`	Logs note+octave (e.g., "C4"). <br>
- `isOnPitch()`	Returns bool if pitch meets precision. <br>
- `getAccuracy()`	Returns pitch confidence in % (0 to 100). <br>
- `getPitchDeviation()`	Returns the pitch deviation in cents (-100 and +100). <br>
- `getVolume()`	Returns normalized volume (0.0 to 100.0). <br>
- `getVolumeFromDbFS()`	Returns volume in dBFS (0.0 to 100.0). <br>
- `isRecording()`	Returns bool if detection is active. <br>
- `getRawDataFromStream()` Returns Processed audio data (normalized doubles). <br>
- `getRawPcmDataFromStream()` Returns raw PCM byte data. <br>

## Important Notes

- **Android-only:** This plugin does not support iOS **yet**. <br>
- **Permissions:** Mic permissions are **automatically handled** on Android. <br>

## Example App

Check the [example/](https://github.com/mattiolichiara/flutter_pitch_detection/tree/main/example) folder for a complete demo app.

## License

[MIT](https://github.com/mattiolichiara/flutter_pitch_detection/blob/main/LICENSE) 
