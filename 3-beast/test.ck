// Eric Heep
// beast.ck

// serial
//Handshake h;
//0.5::second => now;
//h.talk.init();

Connect meepo;
meepo.init();

while (true) {
    meepo.note(0, 127);
    0.2::second => now;
}

/*
Actuate solenoid[1];

for (int i; i < solenoid.size(); i++) {
    solenoid[i].init(i);
    spork ~ actuate(i);
}

fun void actuate(int idx) {
    300::ms => dur step;
    while (true) {
        step => now;
        solenoid[idx].hit(127);
        <<< "!" >>>;
    }
}

while (true) {
    100::ms => now;
}
*/
