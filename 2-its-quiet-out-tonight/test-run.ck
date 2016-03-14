// field-recording.ck
// Eric Heep

// communication classes
HandshakeID talk;
2.5::second => now;
talk.talk.init();
2.5::second => now;

2 => int num;

// led class
Puck puck[num];

for (int i; i < num; i++) {
    // led initialize
    puck[i].init(i);
}

// IDs
// puck 1 - 0
// puck 2 - 1


while (true) {
    for (int i; i < num; i++) {
        for (int j; j < 16; j++) {
            puck[i].color(j, 0, 0, 255);
        }
    }
    1::second => now;
}
