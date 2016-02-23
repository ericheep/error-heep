// RMS.ck
// inexpensive RMS

public class CheapRMS extends Chubgraph {

    inlet => Gain g => OnePole p => blackhole;
    inlet => g;

    // rms stuff
    3 => g.op;
    0.9999 => p.pole;

    fun float decibel() {
        return Std.rmstodb(p.last());
    }
}
