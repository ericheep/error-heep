// Acuate.ck

public class Actuate {

    // static communication object
    Handshake h;

    int solenoid;

    fun void init(int s) {
        s => solenoid;
    }

    fun void hit(int velocity) {
        h.talk.note(solenoid, velocity);
    }

    fun void straight(int velocity, dur speed, dur length) {
        (length/speed) $ int => int iterations;
        for (int i; i < iterations; i++) {
            hit(velocity);
            speed => now;
        }
    }

    // envelope
    fun void envelope(int velocity, int distance, dur speed, dur length) {

        (length/speed) $ int => int iterations;
        iterations/distance => int div;

        if (div == 0) {
            // in case of divide by zero error
            1 => div;
        }

        for (0 => int i; i < iterations/2; i++) {
            if (i % div == 0) {
                5::ms +=> speed;
            }
            hit(velocity);
            speed => now;
        }
        for (iterations/2 => int i; i > 0; i--) {
            if (i % div == 0) {
                5::ms -=> speed;
            }
            hit(velocity);
            speed => now;
        }
    }
}
