// field-recording.ck
// Eric Heep
HandshakeID talk;
2.5::second => now;
talk.talk.init();
2.5::second => now;

1 => int num;
16 => int leds;

// adjust these fellas
16.0 => float RMSAdjust;

NanoKontrol2 nano;

// led class
Puck puck[num];

// audio
SndBuf field[num];
Gain gain[num];
LiSa mic[num];
CheapRMS rms[num];
Features feat[num];

// hsv arrays
float hue[num][leds];
float sat[num][leds];
float val[num][leds];

// red to blue
1024 => int red;
512 => int blue;

["field-1.wav", "field-2.wav"] @=> string file[];

for (int i; i < num; i++) {
    puck[i].init(i);
    field[i] => mic[i] => dac;
    field[i] => gain[i] => dac;
    field[i] => rms[i];
    me.dir() + file[i] => field[i].read;
}

0 => field[0].pos;

fun int convert(float value, int scale) {
    return Std.clamp(Math.floor(value/127.0 * scale) $ int, 0, scale);
}

fun void updateFeatures() {
    // rms brightness, applied equally to all 16 leds
    for (int i; i < num; i++) {
        for (int j; j < leds; j++) {
            rms[i].decibel()/RMSAdjust * nano.slider[i * 4] + nano.knob[i * 4] => val[i][j];
        }
    }
}

fun void updateColors() {
    for (int i; i < num; i++) {
        for (int j; j < 16; j++) {
            puck[i].color(j, 0, 255, convert(val[i][j], 255));
        }
    }
}

while (true) {
    updateFeatures();
    updateColors();
    // <<< rms[0].decibel(), rms[0].decibel()/RMSAdjust * nano.slider[0 * 4] >>>;
    (1.0/30.0)::second => now;
}
