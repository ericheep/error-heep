// serial
Handshake h;
0.5::second => now;
h.talk.init();

// number of actuators
3 => int NUM_ACTUATORS;

// analyze
Analyze ana[NUM_ACTUATORS];

// behavior
Actuate act[NUM_ACTUATORS];

// sound chain
Gain g[NUM_ACTUATORS];

for (int i; i < NUM_ACTUATORS; i++) {
    ana[i].init(i);
    act[i].init(i);
}
