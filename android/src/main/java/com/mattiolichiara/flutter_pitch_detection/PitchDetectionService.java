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
        return Math.round(69 + 12 * (float)(Math.log(frequency / 440.0) / Math.log(2)));
    }

    protected String midiToNoteName(int midi) {
        String[] noteNames = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
        return noteNames[midi % 12];
    }

    protected int midiToOctave(int midi) {
        return (midi / 12) - 1;
    }

    public double getFrequency() {
        return currentFrequency;
    }

    public String getNote() {
        if (currentMidiNote == -1) return null;
        return midiToNoteName(currentMidiNote);
    }

    public int getOctave() {
        if (currentMidiNote == -1) return -1;
        return midiToOctave(currentMidiNote);
    }

    public String printNoteOctave() {
        return getNote() + "" + getOctave();
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

    public double getAccuracy() {
        return accuracy;
    }

    public void start() {
        if (isRecording) return;

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

    public synchronized void stop() {
        if (dispatcher != null && !dispatcher.isStopped()) {
            dispatcher.stop();
            isRecording = false;
        }
    }
}