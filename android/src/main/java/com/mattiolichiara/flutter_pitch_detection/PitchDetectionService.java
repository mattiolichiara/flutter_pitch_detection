package com.mattiolichiara.flutter_pitch_detection;
import be.tarsos.dsp.AudioDispatcher;
import be.tarsos.dsp.io.android.AudioDispatcherFactory;
import be.tarsos.dsp.pitch.PitchDetectionHandler;
import be.tarsos.dsp.pitch.PitchProcessor;
import be.tarsos.dsp.AudioProcessor;
import be.tarsos.dsp.AudioEvent;
import java.util.ArrayList;
import java.util.List;

public class PitchDetectionService {
    private AudioDispatcher dispatcher;
    private final PitchDetectionHandler pitchHandler;
    private int sampleRate;
    private int bufferSize;
    private int overlap;
    private double toleranceCents = 1f;
    private boolean isRecording = false;
    private double currentFrequency = -1f;
    private int currentMidiNote = -1;
    private double minPrecision = 0.85;
    private double lastPitchProbability = 0.0;
    private double volume = 0;
    private double volumeFromDbFS = 0;
    private List<Double> rawAudioData = new ArrayList<>();
    private List<Byte> rawPcmData = new ArrayList<>();

//    public String getPlatformVersion() {
//        return "Android " + android.os.Build.VERSION.RELEASE;
//    }

    public PitchDetectionService(int sampleRate, int bufferSize, int overlap, double toleranceCents, double minPrecision,
                                 PitchDetectionHandler pitchHandler) {
        this.sampleRate = sampleRate;
        this.bufferSize = bufferSize;
        this.overlap = overlap;
        this.toleranceCents = toleranceCents;
        this.minPrecision = minPrecision;
        this.lastPitchProbability = 0.0;
        this.pitchHandler = pitchHandler;
    }

    //RMS
    protected double calculateNormalizedVolume(float[] audioBuffer) {
        double sum = 0.0;
        for (float sample : audioBuffer) {
            sum += sample * sample;
        }

        double rms = Math.sqrt(sum / audioBuffer.length);
        double dbFS = 20 * Math.log10(Math.max(rms, 1e-12));
        return Math.max(0, Math.min(100, (120 + dbFS) * (100.0 / 120.0)));
    }

    protected double calculateNormalizedVolumeFromDbFS(float[] audioBuffer) {
        double dbFS = calculateLoudnessInDbFS(audioBuffer);
        return Math.max(0, Math.min(100, (120 + dbFS) * (100.0 / 120.0)));
    }

    //peak
    protected double calculateLoudnessInDbFS(float[] audioBuffer) {
        if (audioBuffer == null || audioBuffer.length == 0) return 0.0;

        double peak = 0.0;
        for (float sample : audioBuffer) {
            peak = Math.max(peak, Math.abs(sample));
        }
        double dbFS = 20 * Math.log10(Math.max(peak, 1e-12));
        return Math.max(-120, dbFS);
    }

    public int getAccuracy(double toleranceCents) {
        if (currentFrequency <= 0 || currentMidiNote == -1) return 0;

        double targetFrequency = 440.0 * Math.pow(2, (currentMidiNote - 69) / 12.0);

        double maxCents = toleranceCents * 100;

        double ratio = currentFrequency / targetFrequency;
        double centsDeviation = Math.abs(1200 * Math.log10(ratio) / Math.log10(2));

        if (centsDeviation >= maxCents) {
            return 0;
        }

        return (int) Math.round(100 * (1 - (centsDeviation / maxCents)));
    }

    public boolean isOnPitch(double toleranceCents, double minPrecision) {
        if (currentFrequency <= 0 || currentMidiNote == -1) return false;

        double targetFrequency = 440.0 * Math.pow(2, (currentMidiNote - 69) / 12.0);

        double maxCents = toleranceCents * 100;

        double ratio = currentFrequency / targetFrequency;
        double centsDeviation = Math.abs(1200 * Math.log10(ratio) / Math.log10(2));

        double currentPrecision = 1 - (centsDeviation / maxCents);

        return currentPrecision >= minPrecision;
    }

    private double midiToFrequency(int midiNote) {
        return 440.0 * Math.pow(2, (midiNote - 69) / 12.0);
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

    public double getFrequency() {
        return currentFrequency;
    }

    public String getNote() {
        if (currentMidiNote == -1) return "N";
        return midiToNoteName(currentMidiNote);
    }

    public int getMidiNote() {
        if (currentMidiNote == -1) return 0;
        return currentMidiNote;
    }

    public int getOctave() {
        if (currentMidiNote == -1) return -1;
        return midiToOctave(currentMidiNote);
    }

    public synchronized List<Double> getRawDataFromStream() {
        return new ArrayList<>(rawAudioData);
    }

    public synchronized byte[] getRawPcmDataFromStream() {
        byte[] pcmArray = new byte[rawPcmData.size()];
        for (int i = 0; i < rawPcmData.size(); i++) {
            pcmArray[i] = rawPcmData.get(i);
        }
        return pcmArray;
    }

    public String printNoteOctave() {
        return getNote() + "" + getOctave();
    }

    public void setParameters(int sampleRate, int bufferSize, double toleranceCents,
                              double minPrecision) {
        this.sampleRate = sampleRate;
        this.bufferSize = bufferSize;
        this.toleranceCents = toleranceCents;
        this.minPrecision = minPrecision;
    }

    public void setSampleRate(int sampleRate) {
        this.sampleRate = sampleRate;
    }

    public void setBufferSize(int bufferSize) {
        this.bufferSize = bufferSize;
    }

    public void setToleranceCents(double toleranceCents) {
        this.toleranceCents = toleranceCents;
    }

    public void setMinPrecision(double minPrecision) {
        if (minPrecision < 0 || minPrecision > 1) {
            throw new IllegalArgumentException("minPrecision must be between 0 and 1");
        }
        this.minPrecision = minPrecision;
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

    public double getToleranceCents() {
        return toleranceCents;
    }

    public double getMinPrecision() {
        return minPrecision;
    }

    public double getVolume() {
        return volume;
    }

    public double getVolumeFromDbFS() {
        return volumeFromDbFS;
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

            dispatcher.addAudioProcessor(new AudioProcessor() {
                @Override
                public boolean process(AudioEvent audioEvent) {
                    float[] audioBuffer = audioEvent.getFloatBuffer();
                    synchronized (PitchDetectionService.this) {
                        volume = calculateNormalizedVolume(audioBuffer);
                        volumeFromDbFS = calculateNormalizedVolumeFromDbFS(audioBuffer);

                        for (float sample : audioBuffer) {
                            rawAudioData.add((double) sample);

                            short pcmSample = (short) (sample * Short.MAX_VALUE);
                            rawPcmData.add((byte) (pcmSample & 0xff));
                            rawPcmData.add((byte) ((pcmSample >> 8) & 0xff));
                        }

                        if (rawAudioData.size() > sampleRate * 10) {
                            int samplesToKeep = sampleRate;
                            rawAudioData = rawAudioData.subList(rawAudioData.size() - samplesToKeep, rawAudioData.size());
                            rawPcmData = rawPcmData.subList(rawPcmData.size() - (samplesToKeep * 2), rawPcmData.size());
                        }
                    }
                    return true;
                }

                @Override
                public void processingFinished() {
                }
            });

            dispatcher.addAudioProcessor(new PitchProcessor(
                    PitchProcessor.PitchEstimationAlgorithm.FFT_YIN,
                    sampleRate,
                    bufferSize,
                    (pitchResult, audioEvent) -> {
                        float pitch = pitchResult.getPitch();
                        float probability = pitchResult.getProbability();

                        if (pitch > 0 && probability >= minPrecision) {
                            synchronized (this) {
                                currentFrequency = pitch;
                                currentMidiNote = frequencyToMidi(pitch);
                                lastPitchProbability = probability;
                            }
                        } else {
                            synchronized (this) {
                                currentFrequency = -1;
                                currentMidiNote = -1;
                                lastPitchProbability = 0;
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