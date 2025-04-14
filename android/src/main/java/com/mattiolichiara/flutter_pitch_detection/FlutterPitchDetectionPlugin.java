package com.mattiolichiara.flutter_pitch_detection;
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import be.tarsos.dsp.pitch.PitchDetectionHandler;
import com.mattiolichiara.flutter_pitch_detection.*;

import java.util.HashMap;
import java.util.Map;

public class FlutterPitchDetectionPlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
  private static final String CHANNEL = "pitch_detection";
  private static final String EVENT_CHANNEL = "pitch_detection/events";

  private MethodChannel methodChannel;
  private EventChannel eventChannel;
  private EventChannel.EventSink eventSink;
  private PitchDetectionService pitchService;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    methodChannel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
    methodChannel.setMethodCallHandler(this);

    eventChannel = new EventChannel(binding.getBinaryMessenger(), EVENT_CHANNEL);
    eventChannel.setStreamHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {

//      case "getPlatformVersion":
//        result.success("Android " + android.os.Build.VERSION.RELEASE);
//        break;

      case "start":
        int sampleRate = call.argument("sampleRate");
        int bufferSize = call.argument("bufferSize");
        int overlap = call.argument("overlap");

        pitchService = new PitchDetectionService(
                sampleRate != 0 ? sampleRate : 44100,
                bufferSize != 0 ? bufferSize : 1024,
                overlap != 0 ? overlap : 0,
                (resultPitch, event) -> {
                  if (eventSink != null) {
                    Map<String, Object> pitchData = new HashMap<>();
                    pitchData.put("pitch", resultPitch.getPitch());
                    pitchData.put("probability", resultPitch.getProbability());
                    pitchData.put("isPitched", resultPitch.isPitched());
                    eventSink.success(pitchData);
                  }
                }
        );
        pitchService.start();
        result.success(null);
        break;

      case "setParameters":
        try {
          int newSampleRate = call.argument("sampleRate");
          int newBufferSize = call.argument("bufferSize");
          int newOverlap = call.argument("overlap");
          float newAccuracy = call.argument("accuracy") != null ?
                  ((Double) call.argument("accuracy")).floatValue() : 0.8f;

          if (pitchService != null) {
            pitchService.setParameters(
                    newSampleRate != 0 ? newSampleRate : 44100,
                    newBufferSize != 0 ? newBufferSize : 1024,
                    newAccuracy
            );
            result.success(null);
          } else {
            result.error("SERVICE_NOT_RUNNING", "Pitch detection service not running", null);
          }
        } catch (Exception e) {
          result.error("INVALID_PARAMETERS", "Failed to set parameters: " + e.getMessage(), null);
        }
        break;

      case "setSampleRate":
        try {
          int newSampleRate = call.argument("sampleRate");
          if (pitchService != null) {
            pitchService.setSampleRate(
                    newSampleRate != 0 ? newSampleRate : 44100
            );
            result.success(null);
          }
        } catch(Exception e) {
          result.error("INVALID_SAMPLE_RATE", "Failed to set sample rate: " + e.getMessage(), null);
        }
        break;

      case "setBufferSize":
        try {
          int newBufferSize = call.argument("bufferSize");
          if (pitchService != null) {
            pitchService.setBufferSize(
                    newBufferSize != 0 ? newBufferSize : 1024
            );
            result.success(null);
          }
        } catch(Exception e) {
          result.error("INVALID_BUFFER_SIZE", "Failed to set buffer size: " + e.getMessage(), null);
        }
        break;

      case "setAccuracy":
        try {
          float newAccuracy = call.argument("accuracy");
          if (pitchService != null) {
            pitchService.setAccuracy(
                    newAccuracy != 0.0f ? newAccuracy : 1.0f
            );
            result.success(null);
          }
        } catch(Exception e) {
          result.error("INVALID_ACCURACY", "Failed to set accuracy: " + e.getMessage(), null);
        }
        break;

      case "stop":
        if (pitchService != null) {
          pitchService.stop();
        }
        result.success(null);
        break;

      case "isRecording":
        try {
          if (pitchService != null) {
            boolean isRecording = pitchService.isRecording();
            result.success(isRecording);
          } else {
            result.error("SERVICE_NOT_RUNNING", "Pitch detection service not running", null);
          }
        } catch (Exception e) {
          result.error("GET_RECORDING_STATE_FAILED",
                  "Failed to get recording state: " + e.getMessage(), null);
        }
        break;

      case "getSampleRate":
        try {
          if (pitchService != null) {
            sampleRate = pitchService.getSampleRate();
            result.success(sampleRate);
          } else {
            result.error("SERVICE_NOT_RUNNING", "Pitch detection service not running", null);
          }
        } catch (Exception e) {
          result.error("GET_SAMPLE_RATE_FAILED", "Failed to get sample rate: " + e.getMessage(), null);
        }
        break;

      case "getBufferSize":
        try {
          if (pitchService != null) {
            bufferSize = pitchService.getBufferSize();
            result.success(bufferSize);
          } else {
            result.error("SERVICE_NOT_RUNNING", "Pitch detection service not running", null);
          }
        } catch (Exception e) {
          result.error("GET_BUFFER_SIZE_FAILED", "Failed to get buffer size: " + e.getMessage(), null);
        }
        break;

      case "getAccuracy":
        try {
          if (pitchService != null) {
            double accuracy = pitchService.getAccuracy();
            result.success(accuracy);
          } else {
            result.error("SERVICE_NOT_RUNNING", "Pitch detection service not running", null);
          }
        } catch (Exception e) {
          result.error("GET_ACCURACY_FAILED", "Failed to get accuracy: " + e.getMessage(), null);
        }
        break;

      case "getFrequency":
        try {
          if (pitchService != null) {
            double frequency = pitchService.getFrequency();
            result.success(frequency);
          } else {
            result.error("SERVICE_NOT_RUNNING", "Pitch detection service not running", null);
          }
        } catch (Exception e) {
          result.error("GET_FREQUENCY_FAILED", "Failed to get frequency: " + e.getMessage(), null);
        }
        break;

      case "getNote":
        try {
          if (pitchService != null) {
            String note = pitchService.getNote();
            result.success(note);
          } else {
            result.error("SERVICE_NOT_RUNNING", "Pitch detection service not running", null);
          }
        } catch (Exception e) {
          result.error("GET_NOTE_FAILED", "Failed to get note: " + e.getMessage(), null);
        }
        break;

      case "getOctave":
        try {
          if (pitchService != null) {
            int octave = pitchService.getOctave();
            result.success(octave);
          } else {
            result.error("SERVICE_NOT_RUNNING", "Pitch detection service not running", null);
          }
        } catch (Exception e) {
          result.error("GET_OCTAVE_FAILED", "Failed to get octave: " + e.getMessage(), null);
        }
        break;

      case "printNoteOctave":
        try {
          if (pitchService != null) {
            String noteOctave = pitchService.printNoteOctave();
            result.success(noteOctave);
          } else {
            result.error("SERVICE_NOT_RUNNING", "Pitch detection service not running", null);
          }
        } catch (Exception e) {
          result.error("GET_NOTE_OCTAVE_FAILED", "Failed to get note and octave: " + e.getMessage(), null);
        }
        break;

      default:
        result.notImplemented();
    }
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    this.eventSink = events;

    PitchDetectionHandler handler = (result, e) -> {
      float pitch = result.getPitch();
      if (pitch > 0 && eventSink != null) {
        int midi = pitchService.frequencyToMidi(pitch);
        String note = pitchService.midiToNoteName(midi);
        int octave = pitchService.midiToOctave(midi);

        Map<String, Object> data = new HashMap<>();
        data.put("frequency", pitch);
        data.put("note", note);
        data.put("octave", octave);
        data.put("midi", midi);

        eventSink.success(data);
      }
    };

    pitchService = new PitchDetectionService(44100, 2048, 1024, handler);
    pitchService.start();
  }

  @Override
  public void onCancel(Object arguments) {
    if (pitchService != null) {
      pitchService.stop();
      pitchService = null;
    }
    eventSink = null;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    methodChannel.setMethodCallHandler(null);
    eventChannel.setStreamHandler(null);
  }
}