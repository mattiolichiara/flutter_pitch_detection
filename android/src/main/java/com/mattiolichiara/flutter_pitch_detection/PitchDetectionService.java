package android.src.main.java.com.mattiolichiara.flutter_pitch_detection;

import be.tarsos.dsp.AudioDispatcher;
import be.tarsos.dsp.io.android.AudioDispatcherFactory;
import be.tarsos.dsp.pitch.PitchDetectionHandler;
import be.tarsos.dsp.pitch.PitchProcessor;
import be.tarsos.dsp.pitch.PitchProcessor.PitchEstimationAlgorithm;
import android.util.Log;
import io.flutter.plugin.common.MethodChannel.Result;

public class PitchDetectionService {
    private AudioDispatcher dispatcher;
    private boolean isDetecting = false;
    private int sampleRate = 44100;
    private int bufferSize = 2048;
    private int overlap = 1024;
    private float accuracy = 0.01f;
    private OnPitchDetectedListener pitchListener;

    public interface OnPitchDetectedListener {
        void onPitchDetected(double frequency, String note, int octave, double accuracy);
    }

    public void setOnPitchDetectedListener(OnPitchDetectedListener listener) {
        this.pitchListener = listener;
    }

    public void startPitchDetection(Result result) {
        if (isDetecting) {
            result.success(false);
            return;
        }

        try {
            PitchDetectionHandler handler = (pitchDetectionResult, audioEvent) -> {
                if (pitchDetectionResult.getPitch() != -1) {
                    double pitchInHz = pitchDetectionResult.getPitch();
                    double probability = pitchDetectionResult.getProbability();
                    String note = convertFrequencyToNote(pitchInHz);
                    int octave = getOctave(pitchInHz);

                    if (pitchListener != null) {
                        pitchListener.onPitchDetected(pitchInHz, note, octave, probability);
                    }

                    Log.d("PitchDetection", String.format(
                            "Frequency: %.2f Hz, Note: %s, Octave: %d, Accuracy: %.2f",
                            pitchInHz, note, octave, probability
                    ));
                }
            };

            dispatcher = AudioDispatcherFactory.fromDefaultMicrophone(sampleRate, bufferSize, overlap);
            dispatcher.addAudioProcessor(new PitchProcessor(
                    PitchEstimationAlgorithm.YIN,
                    sampleRate,
                    bufferSize,
                    handler
            ));

            new Thread(dispatcher, "Audio Dispatcher").start();
            isDetecting = true;
            result.success(true);
        } catch (Exception e) {
            Log.e("PitchDetection", "Error starting pitch detection", e);
            result.error("START_FAILED", "Failed to start pitch detection: " + e.getMessage(), null);
        }
    }

    public void stopPitchDetection(Result result) {
        if (!isDetecting || dispatcher == null) {
            result.success(false);
            return;
        }

        try {
            dispatcher.stop();
            isDetecting = false;
            result.success(true);
        } catch (Exception e) {
            Log.e("PitchDetection", "Error stopping pitch detection", e);
            result.error("STOP_FAILED", "Failed to stop pitch detection: " + e.getMessage(), null);
        }
    }

    public void setParameters(int sampleRate, int bufferSize, float accuracy, Result result) {
        try {
            this.sampleRate = sampleRate;
            this.bufferSize = bufferSize;
            this.overlap = bufferSize / 2;
            this.accuracy = accuracy;

            result.success(true);
        } catch (Exception e) {
            Log.e("PitchDetection", "Error setting parameters", e);
            result.error("PARAMS_FAILED", "Failed to set parameters: " + e.getMessage(), null);
        }
    }

    public void cleanup() {
        if (dispatcher != null && !dispatcher.isStopped()) {
            dispatcher.stop();
        }
        pitchListener = null;
    }

    private String convertFrequencyToNote(double frequency) {
        String[] notes = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
        double A4 = 440.0;
        int n = (int) Math.round(12 * Math.log(frequency / A4) / Math.log(2));
        return notes[Math.floorMod(n + 69, 12)];
    }

    private int getOctave(double frequency) {
        return (int) (Math.log(frequency / 440.0) / Math.log(2) + 4);
    }
}