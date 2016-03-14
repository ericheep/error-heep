// Features.ck

public class Features extends Chubgraph {

    Spectral spec;
    Subband subband;

    adc => FFT fft => blackhole;
    second / samp => float sr;
    512 => int N => int win => fft.size;
    Windowing.hamming(N) => fft.window;

    UAnaBlob blob;

    float banks[0];
    float cent, spr, flat;
    [0.0, 1000.0, 10000.0, 22050.0] @=> float freqRanges[];

    fun float centroid() {
        return cent;
    }

    fun float flatness() {
        return flat;
    }

    fun float spread() {
        return spr;
    }

    fun float[] filterBanks() {
        return banks;
    }

    fun void analyze() {
        while (true) {
            win::samp => now;
            fft.upchuck() @=> blob;
            spec.centroid(blob.fvals(), sr, N) => cent;
            spec.spread(blob.fvals(), sr, N) => spr;
            subband.filterBanks(blob.fvals(), freqRanges, sr, N) @=> banks;
            <<< flat >>>;
        }
    }

    spork ~ analyze();
}
