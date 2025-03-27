import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
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
    if (call.method.equals("start")) {
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
    } else if (call.method.equals("stop")) {
      if (pitchService != null) {
        pitchService.stop();
      }
      result.success(null);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    eventSink = events;
  }

  @Override
  public void onCancel(Object arguments) {
    eventSink = null;
    if (pitchService != null) {
      pitchService.stop();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    methodChannel.setMethodCallHandler(null);
    eventChannel.setStreamHandler(null);
  }
}