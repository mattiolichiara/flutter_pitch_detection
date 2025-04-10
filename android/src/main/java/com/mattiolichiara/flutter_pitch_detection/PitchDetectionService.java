package com.mattiolichiara.flutter_pitch_detection;
import be.tarsos.dsp.AudioDispatcher;
import be.tarsos.dsp.io.android.AudioDispatcherFactory;
import be.tarsos.dsp.pitch.PitchDetectionHandler;
import be.tarsos.dsp.pitch.PitchProcessor;

public class PitchDetectionService {
    private AudioDispatcher dispatcher;
    private final PitchDetectionHandler pitchHandler;
    private int sampleRate;
    private int bufferSize;
    private int overlap;
    private float accuracy = 1f;
    private boolean isRecording = false;
    private boolean isPermissionGranted = false;

//    public String getPlatformVersion() {
//        return "Android " + android.os.Build.VERSION.RELEASE;
//    }

    public PitchDetectionService(int sampleRate, int bufferSize, int overlap,
                                 PitchDetectionHandler pitchHandler) {
        this.sampleRate = sampleRate;
        this.bufferSize = bufferSize;
        this.overlap = overlap;
        this.pitchHandler = pitchHandler;
        checkAudioPermission();
    }

    public void setParameters(int sampleRate, int bufferSize, float accuracy) {
        this.sampleRate = sampleRate;
        this.bufferSize = bufferSize;
        this.accuracy = accuracy;
    }

    public void setSampleRate(int sampleRate) {
        this.sampleRate = sampleRate;
    }

    public void setBufferSize(int bufferSize) {
        this.bufferSize = bufferSize;
    }

    public void setAccuracy(float accuracy) {
        this.accuracy = accuracy;
    }
    public boolean isRecording() {
        return isRecording;
    }

    public int getSampleRate() {
        return sampleRate;
    }

    public int getBufferSize() {
        return bufferSize;
    }

    public float getAccuracy() {
        return accuracy;
    }

    private void checkAudioPermission() {
        if (ContextCompat.checkSelfPermission(context,
                Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED) {
            isPermissionGranted = true;
        } else {
            if (context instanceof Activity) {
                ActivityCompat.requestPermissions((Activity) context,
                        new String[]{Manifest.permission.RECORD_AUDIO},
                        AUDIO_PERMISSION_REQUEST_CODE);
            }
        }
    }

    public void handlePermissionResult(int requestCode, int[] grantResults) {
        if (requestCode == AUDIO_PERMISSION_REQUEST_CODE) {
            isPermissionGranted = grantResults.length > 0 &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED;
        }
    }

    public void start() {
        dispatcher = AudioDispatcherFactory.fromDefaultMicrophone(
                sampleRate, bufferSize, overlap);

        dispatcher.addAudioProcessor(new PitchProcessor(
                PitchProcessor.PitchEstimationAlgorithm.FFT_YIN,
                sampleRate,
                bufferSize,
                pitchHandler
        ));

        new Thread(dispatcher, "Audio Dispatcher").start();
        isRecording = true;
    }

    public void stop() {
        if (dispatcher != null && !dispatcher.isStopped()) {
            dispatcher.stop();
            isRecording = false;
        }
    }
}