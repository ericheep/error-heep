// field-recording.ck
// Eric Heep
HandshakeID talk;
2.5::second => now;
talk.talk.init();
2.5::second => now;

2 => int num;
16 => int leds;

// adjust these fellas
16.0 => float RMSAdjust;
16.0 => float DBAdjust;
1700.0 * 2 => float centroidAdjust;
1600.0 * 2 => float spreadAdjust;

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

float centroidColor[num];
float spreadLed[num];

3 => int banks;
float filterBanks[num][leds];

[0, 1, 2, 3, 4] @=> int rowOne[];
[5, 6, 7, 8, 9, 10] @=> int rowTwo[];
[11, 12, 13, 14, 15] @=> int rowThree[];

float bankControl;
float easedCentroidColor[num];
float easedSpreadLed[num];

0.5 => float centroidEasingAmount;
0.5 => float spreadEasingAmount;

["field-1.wav", "field-1.wav"] @=> string file[];

for (int i; i < num; i++) {
    puck[i].init(i);
    field[i] => mic[i] => dac.chan(i);
    field[i] => gain[i] => dac.chan(i);
    field[i] => feat[i];
    field[i] => rms[i];

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
            rms[i].decibel()/RMSAdjust * nano.slider[i * 4] + nano.knob[i * 4] => val[i][j];
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
    }

}

fun void updateColors() {
    for (int i; i < num; i++) {
        for (int j; j < 16; j++) {

            // for filterBank stuff
            Std.scalef(filterBanks[i][j], 0, 127, 127, 84.6) => float mappedColor;

            // chooses which led will change
            Std.scalef(easedSpreadLed[i], 0, 127, 0, 15.99) $ int => int whichLed;

            if (j == whichLed) {
                // restricts range from red to blue
                Std.scalef(easedCentroidColor[i], 0, 127, 127, 84.6) => mappedColor;
            }

            // so blue remains the highest color
            Std.clampf(mappedColor, 86.6, 127.0) => mappedColor;

            puck[i].color(j,
                        convert(mappedColor, 1023),     // hue
                        255,                            // saturation, will most likely not change
                        convert(val[i][j], 255));       // value
        }
    }
}

while (true) {
    // mir analysis
    updateFeatures();
    // ease for smoother transitions
    easing();
    // send hsv values to pucks
    updateColors();

    /*
    average << filterBanks[0][0];
    float sum;
    for (int i; i < average.size(); i++) {
        average[i] +=> sum;
    }
    // <<< filterBanks[0][0], sum/average.size() >>>;
    */

    (1.0/30.0)::second => now;
}
