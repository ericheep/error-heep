// its-quiet-out-tonight.ck
// Eric Heep

// communication classes
HandshakeID talk;
2.5::second => now;
talk.talk.init();
2.5::second => now;

2 => int num;
16 => int leds;
16 => int pads;

// adjust these fellas
40.0 => float DBAdjust;
1700.0 * 2 => float centroidAdjust;
1600.0 * 2 => float spreadAdjust;

// midi classes
Quneo quneo;
NanoKontrol2 nano;

// led class
Puck puck[num];

// audio
SndBuf field[num];
Sort sort[num * 2];
int arrowLatch[num * 2];

Gain gain[num];
Phonogene phono[pads];
WinFuncEnv win[pads];
int padLatch[pads];
int offLatch[pads];

// mir
CheapRMS rms[num];
Features feat[num];

// hsv arrays
float hue[num][leds];
float sat[num][leds];
float val[num][leds];
float phonoVal[num][leds];

float centroidColor[num];
float spreadLed[num];
float spreadLed2[num];
float spreadLed3[num];
float spreadLed4[num];

float fieldGain[num];
float easedFieldGain[num];

float sortGain[num * 2];
float easedSortGain[num * 2];

float phonoGain;
float easedPhonoGain;

// phonogene easing
float easedGrainSize[pads];
float grainSize[pads];
float easedGrainPos[pads];
float grainPos[pads];

3 => int banks;
float filterBanks[num][leds];

[0, 1, 2, 3, 4] @=> int rowOne[];
[5, 6, 7, 8, 9, 10] @=> int rowTwo[];
[11, 12, 13, 14, 15] @=> int rowThree[];

float bankControl;
float easedCentroidColor[num];
float easedSpreadLed[num];
float easedSpreadLed2[num];
float easedSpreadLed3[num];
float easedSpreadLed4[num];

0.5 => float centroidEasingAmount;
0.5 => float spreadEasingAmount;

["field-1.wav", "field-2.wav"] @=> string file[];

for (int i; i < num; i++) {
    // led initialize
    puck[i].init(i);

    // for gain
    field[i] => gain[i] => dac.chan(i);
    gain[i] => feat[i];
    gain[i] => rms[i];
    gain[i].gain(0.0);

    // for phonogene
    for (int j; j < pads/2; j++) {
        i * pads/2 + j => int which;
        field[i] => phono[which] => win[which] => dac.chan(i);
        win[which] => feat[i];
        win[which] => rms[i];
        phono[which].gain(0.0);

        // right in the middle
        1.0 => easedGrainPos[which];
        1.0 => grainPos[which];
        phono[which].grainSize(1.0);
        phono[which].grainPos(1.0);
    }

    // for sort
    for (int j; j < num; j++) {
        i * num + j => int which;
        field[i] => sort[which] => dac.chan(i);
        sort[which] => feat[i];
        sort[which] => rms[i];
        sort[which].gain(0.0);
    }

    // read and start recordings
    me.dir() + file[i] => field[i].read;
    0 => field[i].pos;
}

fun int convert(float value, int scale) {
    return Std.clamp(Math.floor(value/127.0 * scale) $ int, 0, scale);
}

fun void updateFeatures() {
    for (int i; i < num; i++) {

        // rms brightness, applied equally to all 16 leds
        for (int j; j < leds; j++) {
            rms[i].decibel()/DBAdjust * nano.slider[i * 4] + nano.knob[i * 4] => val[i][j];
            rms[i].decibel()/DBAdjust * quneo.fader() => phonoVal[i][j];
        }

        // centroid and spread
        feat[i].centroid()/centroidAdjust * nano.slider[i * 4 + 1] + nano.knob[i * 4 + 1] => centroidColor[i];
        feat[i].spread()/spreadAdjust * nano.slider[i * 4 + 2] + nano.knob[i * 4 + 2] => spreadLed[i];

        // filterbank
        for (int j; j < rowOne.size() - 1; j++) {
            filterBanks[i][rowOne[j]] => filterBanks[i][rowOne[j + 1]];
        }
        for (int j; j < rowTwo.size() - 1; j++) {
            filterBanks[i][rowTwo[j]] => filterBanks[i][rowTwo[j + 1]];
        }
        for (int j; j < rowThree.size() - 1; j++) {
            filterBanks[i][rowThree[j]] => filterBanks[i][rowThree[j+ 1]];
        }

        nano.slider[i * 4 + 3] + nano.knob[i * 4 + 3] => bankControl;

        if (feat[i].filterBanks().size() > 0) {
            Std.rmstodb(feat[i].filterBanks()[0])/DBAdjust * bankControl => filterBanks[i][0];
            Std.rmstodb(feat[i].filterBanks()[1])/DBAdjust * bankControl => filterBanks[i][5];
            Std.rmstodb(feat[i].filterBanks()[2])/DBAdjust * bankControl => filterBanks[i][11];
        }
    }
}

fun void easing() {
    for (int i; i < num; i++) {
        // led easing
        for (int j; j < leds; j++) {
            if (easedCentroidColor[i] < centroidColor[i]) {
                centroidEasingAmount +=> easedCentroidColor[i];
            }
            else if (easedCentroidColor[i] > centroidColor[i]) {
                centroidEasingAmount -=> easedCentroidColor[i];
            }
            if (easedSpreadLed[i] < spreadLed[i]) {
                spreadEasingAmount +=> easedSpreadLed[i];
            }
            else if (easedSpreadLed[i] > spreadLed[i]) {
                spreadEasingAmount -=> easedSpreadLed[i];
            }
        }
        // grain size/pos easing
        for (int j; j < leds/2; j++) {
            i * pads/2 + j => int which;

            if (easedGrainSize[which] < grainSize[which]) {
                0.1 +=> easedGrainSize[which];
            }
            else if (easedGrainSize[which] > grainSize[which]) {
                0.1 -=> easedGrainSize[which];
            }
            if (easedGrainPos[which] < grainPos[which]) {
                0.1 +=> easedGrainPos[which];
            }
            else if (easedGrainPos[which] > grainPos[which]) {
                0.1 -=> easedGrainPos[which];
            }
        }
        // gain adjustment easing
        if (easedFieldGain[i] < fieldGain[i]) {
            0.001 +=> easedFieldGain[i];
            gain[i].gain(easedFieldGain[i]);

        }
        else if (easedFieldGain[i] > fieldGain[i]) {
            0.001 -=> easedFieldGain[i];
            gain[i].gain(easedFieldGain[i]);
        }
    }
    // phonogene gain
    if (easedPhonoGain < phonoGain) {
        0.2 +=> easedPhonoGain;
        for (int j; j < pads; j++) {
            phono[j].gain((easedPhonoGain * offLatch[j])/127.0);
        }
    }
    if (easedPhonoGain > phonoGain) {
        0.2 -=> easedPhonoGain;
        for (int j; j < num * 2; j++) {
            phono[j].gain((easedPhonoGain * offLatch[j])/127.0);
        }
    }
    for (int i; i < 4; i++) {
        if (easedSortGain[i] < sortGain[i]) {
            0.1 +=> easedSortGain[i];
            sort[i].gain(easedSortGain[i]/127.0);
        }
        if (easedSortGain[i] > sortGain[i]) {
            0.1 -=> easedSortGain[i];
            sort[i].gain(easedSortGain[i]/127.0);
        }
        quneo.slider(i + 4) => sortGain[i];
    }
}

fun void updateColors() {
    for (int i; i < num; i++) {
        for (int j; j < 16; j++) {

            // for filterBank stuff
            Std.scalef(filterBanks[i][j], 0.0, 127.0, 127.0, 84.6) => float mappedColor;

            // chooses which led will change
            Std.scalef(easedSpreadLed[i], 0.0, 127.0, 0.0, 15.99) $ int => int whichLed;

            if (j == whichLed) {
                // restricts range from red to blue
                Std.scalef(easedCentroidColor[i], 0, 127, 127, 84.6) => mappedColor;
            }

            // so blue remains the highest color
            Std.clampf(mappedColor, 86.6, 127.0) => mappedColor;

            puck[i].color(j,
                        convert(mappedColor, 1023),     // hue
                        255,                            // saturation, will most likely not change
                        convert(Math.max(val[i][j], phonoVal[i][j]), 255)    // value
                        );
        }
    }
}

fun void loop(int idx, int which, dur length) {
    phono[which].record(1);
    length => now;
    phono[which].record(0);

    gain[idx] =< rms[idx];
    gain[idx] =< feat[idx];
    phono[which].play(1);

    win[which].attack(length * 8);
    win[which].release(length * 8);

    1 => offLatch[which];
    win[which].keyOn();
    while (padLatch[which]) {
        1::samp => now;
    }
    win[which].keyOff();
    length * 8 => now;
    0 => offLatch[which];

    gain[idx] => rms[idx];
    gain[idx] => feat[idx];

    phono[which].play(0);
}

fun void sortLoop(int idx, int which) {
    sort[which].stepDuration(Math.random2(30, 60)::ms);
    sort[which].record(1);
    while (arrowLatch[which]) {
        1::ms => now;
    }
    sort[which].record(0);
    sort[which].play(1);
    while (arrowLatch[which] == 0) {
        1::ms => now;
    }
}

fun void loopingControl() {
    for (int i; i < num; i++) {
        nano.slider[i * 4 + 0]/127.0 => fieldGain[i];

        for (int j; j < pads/2; j++) {
            i * pads/2 + j => int which;
            if (quneo.pad(which) > 0 && padLatch[which] == 0) {
                1 => padLatch[which];
                spork ~ loop(i, which, ((j + 1) * 75)::ms);
            }
            if (quneo.pad(which) == 0 && padLatch[which] == 1) {
                0 => padLatch[which];
            }

            quneo.pad(which, "x") => grainSize[which];
            quneo.pad(which, "y") => grainPos[which];
            quneo.fader() => phonoGain;
            phono[which].grainSize(Std.scalef(easedGrainSize[which], 0.0, 127.0, 0.1, 1.0));
            phono[which].grainPos(easedGrainPos[which]/127.0);
        }

        for (int j; j < num; j++) {
            i * num + j => int which;
            if (quneo.arrow(which + 8) > 0 && arrowLatch[which] == 0) {
                1 => arrowLatch[which];
                spork ~ sortLoop(i, which);
            }
            if (quneo.arrow(which + 8) == 0 && arrowLatch[which] == 1) {
                0 => arrowLatch[which];
            }
        }
    }
}

// int inc;
// float average[0];

while (true) {
    // audio manipulation
    loopingControl();
    // mir analysis
    updateFeatures();
    // ease for smoother transitions
    easing();
    // send hsv values to pucks
    updateColors();

    /* average << rms[0].decibel();
    float sum;
    for (int i; i < average.size(); i++) {
        average[i] +=> sum;
    }
    <<< sum/average.size() >>>;
    */
    (1.0/30.0)::second => now;
}
