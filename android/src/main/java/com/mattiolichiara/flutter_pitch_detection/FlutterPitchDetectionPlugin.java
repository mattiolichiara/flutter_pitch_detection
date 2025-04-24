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
import android.os.Handler;
import android.os.Looper;
import io.flutter.plugin.common.PluginRegistry;

import java.util.HashMap;
import java.util.Map;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.Manifest;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import java.util.ArrayList;
import java.util.List;

public class FlutterPitchDetectionPlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener {
  private static final String CHANNEL = "pitch_detection/methods";
  private static final String EVENT_CHANNEL = "pitch_detection/events";

  private MethodChannel methodChannel;
  private EventChannel eventChannel;
  private EventChannel.EventSink eventSink;
  private PitchDetectionService pitchService;
  private final Object sinkLock = new Object();
  private Activity activity;
  private Context context;
  private int sampleRate;
  private int bufferSize;
  private MethodChannel.Result pendingResult;
  private MethodCall pendingCall;

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    this.activity = binding.getActivity();
    binding.addRequestPermissionsResultListener(this);
  }

  @Override
  public void onDetachedFromActivity() {
    this.activity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    this.activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    this.activity = null;
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    if (requestCode == 1001) {
      if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
        if (pendingCall != null && pendingResult != null) {
          startPitchDetection(pendingCall, pendingResult);
        }
      } else {
        if (pendingResult != null) {
          pendingResult.error("PERMISSION_DENIED", "Microphone permission not granted", null);
        }
      }
      pendingCall = null;
      pendingResult = null;
      return true;
    }
    return false;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    context = binding.getApplicationContext();
    methodChannel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
    methodChannel.setMethodCallHandler(this);

    eventChannel = new EventChannel(binding.getBinaryMessenger(), EVENT_CHANNEL);
    eventChannel.setStreamHandler(this);
  }

  private void startPitchDetection(MethodCall call, Result result) {
    int sampleRate = call.argument("sampleRate");
    int bufferSize = call.argument("bufferSize");
    int overlap = call.argument("overlap");
    double toleranceCents = call.argument("toleranceCents") != null ?
            ((Double) call.argument("toleranceCents")).doubleValue() : 0.5;
    double minPrecision = call.argument("minPrecision") != null ?
            ((Double) call.argument("minPrecision")).doubleValue() : 0.8;

    if (pitchService != null) {
      pitchService.stopDetection();
    }

    pitchService = new PitchDetectionService(
            sampleRate != 0 ? sampleRate : 44100,
            bufferSize != 0 ? bufferSize : 2048,
            overlap != 0 ? overlap : 1024,
            toleranceCents != 0.0f ? toleranceCents : 1.0f,
            minPrecision != 0.0f ? minPrecision : 0.8,
            pitchHandler
    );
    pitchService.startDetection();
    result.success(null);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {

//      case "getPlatformVersion":
//        result.success("Android " + android.os.Build.VERSION.RELEASE);
//        break;

      case "startDetection":
        if (ContextCompat.checkSelfPermission(activity, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
          pendingCall = call;
          pendingResult = result;
          ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.RECORD_AUDIO}, 1001);
        } else {
          startPitchDetection(call, result);
        }
        break;

      case "setParameters":
        try {
          int newSampleRate = call.argument("sampleRate");
          int newBufferSize = call.argument("bufferSize");
          double newToleranceCents = call.argument("toleranceCents") != null ?
                  ((Double) call.argument("toleranceCents")).doubleValue() : 0.5;
          double newMinPrecision = call.argument("minPrecision") != null ?
                  ((Double) call.argument("minPrecision")).doubleValue() : 0.8;

          if (pitchService != null) {
            pitchService.setParameters(
                    newSampleRate != 0 ? newSampleRate : 44100,
                    newBufferSize != 0 ? newBufferSize : 1024,
                    newToleranceCents != 0.0f ? newToleranceCents : 1.0f,
                    newMinPrecision != 0.0f ? newMinPrecision : 0.8
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

      case "stopDetection":
        if (pitchService != null) {
          pitchService.stopDetection();
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

      case "getMidiNote":
        try {
          if (pitchService != null) {
            int midiNote = pitchService.getMidiNote();
            result.success(midiNote);
          } else {
            result.error("SERVICE_NOT_RUNNING", "Pitch detection service not running", null);
          }
        } catch (Exception e) {
          result.error("GET_MIDI_NOTE_FAILED", "Failed to get midi note: " + e.getMessage(), null);
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

      case "setToleranceCents":
        try {
          double newToleranceCents = call.argument("toleranceCents");
          if (pitchService != null) {
            pitchService.setToleranceCents(
                    newToleranceCents != 0.0 ? newToleranceCents : 1.0
            );
            result.success(null);
          } else {
            result.error("SERVICE_NOT_RUNNING", "Pitch detection service not running", null);
          }
        } catch (Exception e) {
          result.error("SET_TOLERANCE_FAILED", "Failed to set tolerance: " + e.getMessage(), null);
        }
        break;

      case "getToleranceCents":
        try {
          if (pitchService != null) {
            result.success(pitchService.getToleranceCents());
          } else {
            result.error("SERVICE_NOT_RUNNING", "Service not running", null);
          }
        } catch (Exception e) {
          result.error("GET_TOLERANCE_FAILED", "Failed to get tolerance: " + e.getMessage(), null);
        }
        break;

      case "setMinPrecision":
        try {
          double newMinPrecision = call.argument("minPrecision");
          if (pitchService != null) {
            pitchService.setMinPrecision(
                    newMinPrecision != 0.0 ? newMinPrecision : 0.8
            );
            result.success(null);
          } else {
            result.error("SERVICE_NOT_RUNNING", "Service not running", null);
          }
        } catch (Exception e) {
          result.error("SET_PRECISION_FAILED", "Failed to set precision: " + e.getMessage(), null);
        }
        break;

      case "getMinPrecision":
        try {
          if (pitchService != null) {
            result.success(pitchService.getMinPrecision());
          } else {
            result.error("SERVICE_NOT_RUNNING", "Service not running", null);
          }
        } catch (Exception e) {
          result.error("GET_PRECISION_FAILED", "Failed to get precision: " + e.getMessage(), null);
        }
        break;

      case "isOnPitch":
        try {
          if (pitchService != null) {
            double tolerance = call.argument("toleranceCents");
            double precision = call.argument("minPrecision");
              result.success(pitchService.isOnPitch(tolerance, precision));
          } else {
            result.error("SERVICE_NOT_RUNNING", "Service not running", null);
          }
        } catch (Exception e) {
          result.error("PITCH_CHECK_FAILED", "Failed to check pitch: " + e.getMessage(), null);
        }
        break;

      case "getAccuracy":
        try {
          if (pitchService != null) {
            Double tolerance = call.argument("toleranceCents");
            if (tolerance == null) {
              result.error("MISSING_PARAMETER", "toleranceCents parameter is required", null);
            } else {
              int accuracy = pitchService.getAccuracy(tolerance);
              result.success(accuracy);
            }
          } else {
            result.error("SERVICE_NOT_RUNNING", "Pitch detection service not running", null);
          }
        } catch (Exception e) {
          result.error("ACCURACY_CHECK_FAILED", "Failed to check accuracy: " + e.getMessage(), null);
        }
        break;

      case "getVolume":
        try {
          if (pitchService != null) {
            double volume = pitchService.getVolume();
            result.success(volume);
          } else {
            result.error("SERVICE_NOT_RUNNING", "Pitch detection service not running", null);
          }
        } catch (Exception e) {
          result.error("VOLUME_CHECK_FAILED", "Failed to get volume: " + e.getMessage(), null);
        }
        break;

      case "getVolumeFromDbFS":
        try {
          if (pitchService != null) {
            double volume = pitchService.getVolumeFromDbFS();
            result.success(volume);
          } else {
            result.error("SERVICE_NOT_RUNNING", "Pitch detection service not running", null);
          }
        } catch (Exception e) {
          result.error("VOLUME_CHECK_FAILED", "Failed to get dBFS volume: " + e.getMessage(), null);
        }
        break;
      case "getRawDataFromStream":
        try {
          if (pitchService != null) {
            result.success(pitchService.getRawDataFromStream());
          } else {
            result.error("NOT_INITIALIZED", "Pitch detection not started", null);
          }
        } catch(Exception e) {
          result.error("GET_RAW_DATA_FROM_STREAM_FAILED", "Failed to get dBFS volume: " + e.getMessage(), null);
        }
        break;

      case "getRawPcmDataFromStream":
        try {
          if (pitchService != null) {
            result.success(pitchService.getRawPcmDataFromStream());
          } else {
            result.error("NOT_INITIALIZED", "Pitch detection not started", null);
          }
        } catch(Exception e) {
          result.error("GET_RAW_PCM_DATA_FROM_STREAM_FAILED", "Failed to get dBFS volume: " + e.getMessage(), null);
        }
        break;

      default:
        result.notImplemented();
    }
  }

  private final PitchDetectionHandler pitchHandler = (pitchResult, audioEvent) -> {
    float pitch = pitchResult.getPitch();
    if (pitch <= 0) return;

    new Handler(Looper.getMainLooper()).post(() -> {
      synchronized (sinkLock) {
        if (eventSink != null) {
          int midi = pitchService.frequencyToMidi(pitch);
          Map<String, Object> data = new HashMap<>();
          data.put("frequency", pitch);
          data.put("note", pitchService.midiToNoteName(midi));
          data.put("octave", pitchService.midiToOctave(midi));
          data.put("midi", midi);
          data.put("volume", pitchService.getVolume());
          data.put("volumeDbFS", pitchService.getVolumeFromDbFS());

          eventSink.success(data);
        }
      }
    });
  };

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    synchronized (sinkLock) {
      this.eventSink = events;
    }

    if (pitchService == null) {
      pitchService = new PitchDetectionService(44100, 2048, 1024, 0.5, 0.8, pitchHandler);
      pitchService.startDetection();
    }
  }

  @Override
  public void onCancel(Object arguments) {
    if (pitchService != null) {
      pitchService.stopDetection();
      pitchService = null;
    }
    eventSink = null;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (pitchService != null) {
      pitchService.stopDetection();
      pitchService = null;
    }
    methodChannel.setMethodCallHandler(null);
    eventChannel.setStreamHandler(null);
  }
}