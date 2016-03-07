// field-recording.ck
// Eric Heep

// communication classes
HandshakeID talk;
2.5::second => now;
talk.talk.init();
2.5::second => now;

2 => int num;

// led class
// Puck puck[num];

for (int i; i < num; i++) {
    // led initialize
    // puck[i].init(i);
}

// motor class
Motor motor;
motor.init(2);

// IDs
// puck 1 - 0
// puck 2 - 1
// motor  - 2

0 => int forward;
1 => int reverse;

10 => int steps;

while (true) {
    // <<< "Motor:", 0, "Steps", steps, "Direction", forward, "" >>>;
    motor.move(0, steps, forward);
    1::second => now;
    // (1.0/30.0)::second => now;
    // motor one, rotations, direction
}
