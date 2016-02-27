// Analyze.ck
// class that analyzes indivdual channels and returns
// information about them

public class Analyze extends Chubgraph {

    inlet => Gain g => OnePole p => blackhole;
    inlet => g;

    // rms stuff
    3 => g.op;
    0.9999 => p.pole;

    int solenoid;

    fun void init(int idx) {
        idx => solenoid;
    }

    fun float decibel() {
        return Std.rmstodb(p.last());
    }

    // merely holds until a spike is heard above a certain level
    fun void decibelSpike(float db) {
        while (decibel() < db) {
            1::samp => now;
        }
    }
}
