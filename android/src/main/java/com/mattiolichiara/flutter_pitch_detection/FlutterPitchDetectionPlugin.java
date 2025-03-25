package android.src.main.java.com.mattiolichiara.flutter_pitch_detection;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import android.Manifest;
import android.content.pm.PackageManager;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class FlutterPitchDetectionPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  private MethodChannel channel;
  private EventChannel eventChannel;
  private EventSink eventSink;
  private static final int PERMISSION_REQUEST_CODE = 200;
  private final PitchDetectionService pitchDetectionService = new PitchDetectionService();
  private ActivityPluginBinding activityBinding;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_pitch_detection");
    eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_pitch_detection_stream");
    channel.setMethodCallHandler(this);

    eventChannel.setStreamHandler(new StreamHandler() {
      @Override
      public void onListen(Object arguments, EventSink events) {
        eventSink = events;
        pitchDetectionService.setOnPitchDetectedListener((frequency, note, octave, accuracy) -> {
          if (eventSink != null) {
            eventSink.success(String.format("{\"frequency\": %.2f, \"note\": \"%s\", \"octave\": %d, \"accuracy\": %.2f}",
                    frequency, note, octave, accuracy));
          }
        });
      }

      @Override
      public void onCancel(Object arguments) {
        eventSink = null;
        pitchDetectionService.setOnPitchDetectedListener(null);
      }
    });
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (activityBinding == null || activityBinding.getActivity() == null) {
      result.error("UNAVAILABLE", "Activity not attached", null);
      return;
    }

    switch (call.method) {
      case "startPitchDetection":
        pitchDetectionService.startPitchDetection(result);
        break;
      case "stopPitchDetection":
        pitchDetectionService.stopPitchDetection(result);
        break;
      case "setParameters":
        int sampleRate = call.argument("sampleRate");
        int bufferSize = call.argument("bufferSize");
        float accuracy = call.argument("accuracy");
        pitchDetectionService.setParameters(sampleRate, bufferSize, accuracy, result);
        break;
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "checkPermission":
        boolean hasPermission = ContextCompat.checkSelfPermission(
                activityBinding.getActivity(),
                Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED;
        result.success(hasPermission);
        break;
      case "requestPermission":
        ActivityCompat.requestPermissions(
                activityBinding.getActivity(),
                new String[]{Manifest.permission.RECORD_AUDIO},
                PERMISSION_REQUEST_CODE);
        // Return immediately, actual result will come through onRequestPermissionsResult
        result.success(null);
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    if (requestCode == PERMISSION_REQUEST_CODE) {
      boolean granted = grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED;
      channel.invokeMethod("onPermissionResult", granted);
      return true;
    }
    return false;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    this.activityBinding = binding;
    binding.addRequestPermissionsResultListener(this);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    if (activityBinding != null) {
      activityBinding.removeRequestPermissionsResultListener(this);
      activityBinding = null;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    if (eventChannel != null) {
      eventChannel.setStreamHandler(null);
    }
    pitchDetectionService.cleanup();
  }
}