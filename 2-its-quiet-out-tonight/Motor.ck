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

    fun void move(int motor, int steps, int direction) {
        // ensuring the proper values get sent
        steps % 1024 => steps;
        Std.clamp(direction, 0, 255) => direction;
        <<< port, motor, steps, direction, 0 >>>;
        talk.talk.packet(port, motor, steps, direction, 0);
    }
}
