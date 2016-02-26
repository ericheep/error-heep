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
}
