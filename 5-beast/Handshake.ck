// Handshake.ck
// Eric Heep
// creates a static instantiation of the Connect class
// allows child bot classes to send serial through it

public class Handshake {
    static Connect @ talk;
}

new Connect @=> Handshake.talk;
