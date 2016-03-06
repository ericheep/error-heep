// Motor.ck
// Eric Heep
// communication

public class Motor {
    HandshakeID talk;
    int port;

    fun void init(int which) {
        IDCheck(which) => port;
    }

    fun int IDCheck(int arduinoID) {
        -1 => int check;
        for (int i; i < talk.talk.robotID.cap(); i++) {
            if (arduinoID == talk.talk.robotID[i]) {
                <<< "Motor", talk.talk.robotID[i], "connected to port", i + "." >>>;
                i => check;
            }
        }
        if (check == -1) {
            <<< "unable to connect">>>;
        }
        return check;
    }

    // receives OSC and sends out serial
    fun void color(int motor, int rotations, int direction, int val) {
        // ensuring the proper values get sent
        rotations % 1024 => rotations;
        Std.clamp(direction, 0, 255) => direction;
        Std.clamp(val, 0, 255) => val;

        talk.talk.packet(port, motor, rotations, direction, val);
    }
}
