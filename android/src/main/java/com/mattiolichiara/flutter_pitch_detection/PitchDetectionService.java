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
    private double accuracy = 1f;
    private boolean isRecording = false;
    private double currentFrequency = -1f;
    private int currentMidiNote = -1;
    private double decibels = 0;



//    public String getPlatformVersion() {
//        return "Android " + android.os.Build.VERSION.RELEASE;
//    }

    public PitchDetectionService(int sampleRate, int bufferSize, int overlap,
                                 PitchDetectionHandler pitchHandler) {
        this.sampleRate = sampleRate;
        this.bufferSize = bufferSize;
        this.overlap = overlap;
        this.pitchHandler = pitchHandler;
    }

    protected int frequencyToMidi(float frequency) {
        if (frequency <= 0) return -1;
        return (int) Math.round(69 + 12 * (Math.log(frequency / 440.0) / Math.log(2)));
    }

    protected String midiToNoteName(int midi) {
        String[] noteNames = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
        if (midi < 0 || midi > 127) return "N";
        return noteNames[midi % 12];
    }

    protected int midiToOctave(int midi) {
        return (midi / 12) - 1;
    }

    protected double calculateLoudnessInDbSPL(float[] audioBuffer) {
        if (audioBuffer == null || audioBuffer.length == 0) {
            return 0.0;
        }

        final double referencePressure = 20e-6;
        final double epsilon = 1e-12;

        double sum = 0.0;
        for (float sample : audioBuffer) {
            sum += sample * sample;
        }
        double rms = Math.sqrt(sum / audioBuffer.length);

        double ratio = rms / referencePressure;
        double dbSPL = 20 * Math.log10(Math.max(ratio, epsilon));

        return Math.max(0, Math.min(dbSPL, 140));
    }

    public double getFrequency() {
        return currentFrequency;
    }

    public String getNote() {
        if (currentMidiNote == -1) return "N";
        return midiToNoteName(currentMidiNote);
    }

    public int getOctave() {
        if (currentMidiNote == -1) return -1;
        return midiToOctave(currentMidiNote);
    }

    public String printNoteOctave() {
        return getNote() + "" + getOctave();
    }

    public void setParameters(int sampleRate, int bufferSize, double accuracy) {
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

    public void setAccuracy(double accuracy) {
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

    public double getAccuracy() {
        return accuracy;
    }

    public double getDecibels() {
        return decibels;
    }

    public synchronized void startDetection() {
        if (isRecording) return;

        try {
            if (bufferSize < 7056) bufferSize = 8192;

            dispatcher = AudioDispatcherFactory.fromDefaultMicrophone(
                    sampleRate,
                    bufferSize,
                    overlap
            );

            dispatcher.addAudioProcessor(new PitchProcessor(
                    PitchProcessor.PitchEstimationAlgorithm.FFT_YIN,
                    sampleRate,
                    bufferSize,
                    (pitchResult, audioEvent) -> {
                        float pitch = pitchResult.getPitch();
                        if (pitch > 0 && pitchResult.getProbability() > 0.9) {
                            synchronized (this) {
                                currentFrequency = pitch;
                                currentMidiNote = frequencyToMidi(pitch);
                            }
                        } else {
                            synchronized (this) {
                                currentFrequency = -1;
                                currentMidiNote = -1;
                            }
                        }
                        pitchHandler.handlePitch(pitchResult, audioEvent);
                    }
            ));

            new Thread(dispatcher, "Audio Dispatcher").start();
            isRecording = true;

        } catch (Exception e) {
            stopDetection();
            throw new RuntimeException("Start failed: " + e.getMessage(), e);
        }
    }

    public synchronized void stopDetection() {
        if (dispatcher != null && !dispatcher.isStopped()) {
            dispatcher.stop();
            isRecording = false;
        }
    }
}