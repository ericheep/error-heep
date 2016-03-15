// check-odradek-check.ck
// Eric Heep, March 10th 2016

// set number of channels

// midi control
NanoKontrol2 nano;
// 0, basic left/right microlooping of "check", sparsely spaced, can switch to illusion microloops
// 1, "reich bed" off of same original "check"
// 2, sort, a way to ease into cacophony
// 3, left/right LisaCluster for cacophony to dry
// 4, left/right LisaCluster for cacophony to dry
// 6, speed gate, left
// 7, speed gate, right
// 8, hard stop on all volume, volume fade, might not use

// speech
adc => Gain input => Gain inputGain => Pan2 inputPan => LPF lpf => HPF hpf => dac;

hpf.freq(340);

inputPan.gain(0.5);
inputPan.left => dac.left;
inputPan.right => dac.right;

1.0 => float globalGain;
inputGain.gain(0.0);

// ~ FFTNoise ~~~~~~~~~~~~~~~~~~~~~~~~~~
adc => FFTNoise fft => Pan2 fftPan;

fftPan.left => dac.chan(0);
fftPan.right => dac.chan(1);

fft.listen(1);

// for balancing the two
float globalMix;
float ease_globalMix;
0.0 => float inputMix;
1.0 => float noiseMix;


// ~ Gate ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
2 => int g_num;
float g_rate[g_num];
float ease_g_rate[g_num];


// ~ Check ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
2 => int c_num;

LiSa check[c_num];
LiSa noiseCheck[c_num];
Pan2 checkPan[c_num];
Pan2 noiseCheckPan[c_num];

float checkGate[c_num];
float noiseCheckGate[c_num];

for (0 => int i; i < c_num; i++) {
    input => check[i] => checkPan[i] => dac;
    fft => noiseCheck[i] => noiseCheckPan[i] => dac;
    checkPan[i].gain(1.0);
    noiseCheckPan[i].gain(1.0);
    check[i].duration(3::second);
    noiseCheck[i].duration(3::second);
    check[i].loop(0);
    noiseCheck[i].loop(0);
    check[i].gain(0.0);
    noiseCheck[i].gain(0.0);
    1.0 => checkGate[i];
    1.0 => noiseCheckGate[i];
}

checkPan[0].pan(-1.0);
noiseCheckPan[0].pan(-1.0);

checkPan[1].pan(1.0);
noiseCheckPan[1].pan(1.0);

int c_state;
int c_recordActive;
int c_playActive;
int c_latch;
float c_vol;
float ease_c_vol;
float c_space;
dur c_dur;


// ~ Reich ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
3 => int r_num;
0 => int r_mod;

Reich reich[r_num];
Reich noiseReich[r_num];
Gain reichGains[2];

for (0 => int i; i < r_num; i++) {
    input => reich[i] => reichGains[0] => dac.left;
    reich[i] => reichGains[1] => dac.right;
    fft => noiseReich[i] => reichGains[0] => dac.left;
    noiseReich[i] => reichGains[1] => dac.right;

    // reich initialize functions
    reich[i].gain(0.0);
    reich[i].randomPos(1);
    reich[i].voices(32);
    reich[i].bi(1);
    reich[i].randomPos(1);

    // reich initialize functions
    noiseReich[i].gain(0.0);
    noiseReich[i].randomPos(1);
    noiseReich[i].voices(32);
    noiseReich[i].bi(1);
    noiseReich[i].randomPos(1);

}

int r_vol;
int r_spd;
int r_latch;
int r_state;


// ~ Sort ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
3 => int s_num;
0 => int s_mod;

Sort sort[s_num];
Sort noiseSort[s_num];
Pan2 panSort;
Gain sortGains[2];

for (0 => int i; i < s_num; i++) {
    input => sort[i] => panSort;
    sort[i].stepDuration(50::ms);
    fft => noiseSort[i] => panSort;
    noiseSort[i].stepDuration(50::ms);
}

// sort sound chain
panSort => sortGains[0] => dac.left;
panSort => sortGains[1] => dac.right;

float s_vol;
int s_state;
int s_latch;
int s_pan;
float s_spin;

float ease_s_vol;


// ~ LiSaCluster ~~~~~~~~~~~~~~~~~~~~~~~
LiSaCluster2 lisaCluster[2];
lisaCluster.size() => int lc_num;

LiSaCluster2 noiseLisaCluster[lc_num];

// LiSaCluster setup
for (0 => int i; i < lc_num; i++) {
    // lisaCluster sound chain
    input => lisaCluster[i];
    fft => noiseLisaCluster[i];
    // lisaCluster initialize functions
    lisaCluster[i].fftSize(1024);
    lisaCluster[i].gain(0.0);
    lisaCluster[i].numClusters(2);
    noiseLisaCluster[i].fftSize(1024);
    noiseLisaCluster[i].gain(0.0);
    noiseLisaCluster[i].numClusters(2);
}

// features for first cluster
lisaCluster[0].centroid(1);
lisaCluster[0].crest(1);
noiseLisaCluster[0].centroid(1);
noiseLisaCluster[0].crest(1);

// features for second cluster
lisaCluster[1].hfc(1);
lisaCluster[1].subbandCentroids(1);
noiseLisaCluster[1].hfc(1);
noiseLisaCluster[1].subbandCentroids(1);

float lc_vol[lc_num];
float ease_lc_vol[lc_num];
int lc_latch[lc_num];
int lc_state[lc_num];
int lc_pan[lc_num];
int lc_cluster[lc_num];


// ~ SpeedGate
float sg_rate;
float sg_vol;
float ease_sg_vol;

.5 => c_space;

// Check controls
fun void checkParams() {
    0 => int position;
    if (nano.rec[position] && c_latch == 0) {
        1 => c_recordActive;
        0 => c_playActive;
        1 => c_latch;
        spork ~ checkRecord();
    }
    if (nano.rec[position] == 0 && c_latch) {
        0 => c_recordActive;
        0 => c_latch;
        spork ~ checkPlay();
    }
    if (nano.knob[position] != c_space) {
        nano.knob[position] => c_space;
    }
    // gain
    if (nano.slider[position] != ease_c_vol) {
        nano.slider[position] => ease_c_vol;
    }
}

fun void checkRecord() {
    for (0 => int i; i < c_num; i++) {
        check[i].record(1);
        noiseCheck[i].record(1);
    }

    now => time past;

    while (c_recordActive) {
        1::samp => now;
    }
    now - past => c_dur;

    for (0 => int i; i < c_num; i++) {
        check[i].record(0);
        noiseCheck[i].record(0);
    }
}

fun void checkPlay() {
    1 => c_playActive;
    while (c_playActive) {
        check[0].play(1);
        noiseCheck[0].play(1);
        check[0].playPos(0::samp);
        noiseCheck[0].playPos(0::samp);
        c_dur * (c_space/127.0 * 20 + 0.5) => now;

        check[1].play(1);
        noiseCheck[1].play(1);
        check[1].playPos(0::samp);
        noiseCheck[1].playPos(0::samp);
        c_dur * (c_space/127.0 * 20 + 0.5) => now;
    }
}

// Reich controls
fun void reichParams() {
    1 => int positionOffset;
    // active/inactive
    if (nano.mute[positionOffset] != r_state) {
        nano.mute[positionOffset] => r_state;
        // turns on/off gain
        if (r_state) {
            reich[r_mod].gain(r_vol);
            noiseReich[r_mod].gain(r_vol);
        }
        else {
            reich[r_mod].gain(0.0);
            noiseReich[r_mod].gain(0.0);
        }
    }
    // speed
    if (nano.knob[positionOffset] != r_spd) {
        nano.knob[positionOffset] => r_spd;
        reich[r_mod].speed(r_spd/127.0 * 2.0);
        noiseReich[r_mod].speed(r_spd/127.0 * 2.0);
    }
    // gain
    if (nano.slider[positionOffset] != r_vol) {
        nano.slider[positionOffset] => r_vol;
    }
    // record
    if (nano.rec[positionOffset] && r_latch == 0) {
        (1 + r_mod) % r_num => r_mod;

        reich[r_mod].play(0);
        reich[r_mod].record(1);
        noiseReich[r_mod].play(0);
        noiseReich[r_mod].record(1);
        1 => r_latch;
    }
    if (nano.rec[positionOffset] == 0 && r_latch) {
        reich[r_mod].record(0);
        reich[r_mod].play(1);
        noiseReich[r_mod].record(0);
        noiseReich[r_mod].play(1);
        0 => r_latch;
    }
}


// Reich panning
fun void reichWobble() {
    [0.5, 10.0] @=> float panResetTimes[];
    0.2 => float panRange;
    while (true) {
        Math.random2f(panResetTimes[0], panResetTimes[1])::second => dur panReset;
        now => time start;
        0.0 => float pan;
        while (now < start + panReset) {
            if (pan > panRange) {
                pan - panRange * 2.0 => pan;
            }
            (pan + 0.001) => pan;
            1::ms => now;
        }
    }
}

// input/FFTNoise panning
fun void fftWobble() {
    [0.5, 10.0] @=> float panResetTimes[];
    0.2 => float panRange;
    while (true) {
        Math.random2f(panResetTimes[0], panResetTimes[1])::second => dur panReset;
        now => time start;
        0.0 => float pan;
        while (now < start + panReset) {
            if (pan > panRange) {
                pan - panRange * 2.0 => pan;
            }
            (pan + 0.001) => pan;
            fftPan.pan(pan);
            inputPan.pan(pan);
            1::ms => now;
        }
    }
}

// LiSaCluster controls
fun void lisaClusterParams() {
    3 => int positionOffset;
    [50.0, 100.0] @=> float stepLengths[];

    for (0 => int i; i < lc_num; i++) {
        // active/inactive
        if (nano.mute[i + positionOffset] != lc_state[i]) {
            nano.mute[i + positionOffset] => lc_state[i];
            // turns on/off gain
            if (lc_state[i]) {
                lisaCluster[i].gain(lc_vol[i]);
                noiseLisaCluster[i].gain(lc_vol[i]);
            }
            else {
                lisaCluster[i].gain(0.0);
                noiseLisaCluster[i].gain(0.0);
            }
        }
        // gain
        if (nano.slider[i + positionOffset] != ease_lc_vol[i]) {
            nano.slider[i + positionOffset] => ease_lc_vol[i];
        }

        if (nano.knob[i + positionOffset] != lc_cluster[i]) {
            nano.knob[i + positionOffset] => lc_cluster[i];
        }
        // record
        if (nano.rec[i + positionOffset] && lc_latch[i] == 0) {
            lisaCluster[i].stepLength(Math.random2f(stepLengths[0], stepLengths[1])::ms);
            lisaCluster[i].play(0);
            lisaCluster[i].record(1);
            noiseLisaCluster[i].stepLength(Math.random2f(stepLengths[0], stepLengths[1])::ms);
            noiseLisaCluster[i].play(0);
            noiseLisaCluster[i].record(1);
            1 => lc_latch[i];
        }
        if (nano.rec[i + positionOffset] == 0 && lc_latch[i]) {
            lisaCluster[i].record(0);
            lisaCluster[i].play(1);
            noiseLisaCluster[i].record(0);
            noiseLisaCluster[i].play(1);
            0 => lc_latch[i];
        }
    }
}

// Sort controls
fun void sortParams() {
    2 => int positionOffset;
     // active/inactive
    if (nano.mute[positionOffset] != s_state) {
        nano.mute[positionOffset] => s_state;
        // turns on/off gain
        if (s_state) {
            sort[s_mod].gain(s_vol);
            noiseSort[s_mod].gain(s_vol);
        }
        else {
            sort[s_mod].gain(0.0);
            noiseSort[s_mod].gain(0.0);
        }
    }
    // gain
    if (nano.slider[positionOffset] != ease_s_vol) {
        nano.slider[positionOffset] => ease_s_vol;
    }
    // pan
    if (nano.knob[positionOffset] != s_pan) {
        nano.knob[positionOffset] => s_pan;
        (s_pan/127.0) * 0.01 => s_spin;
    }
    // record
    if (nano.rec[positionOffset] && s_latch == 0) {
        (1 + s_mod) % s_num => s_mod;

        sort[s_mod].play(0);
        sort[s_mod].record(1);
        noiseSort[s_mod].play(0);
        noiseSort[s_mod].record(1);
        1 => s_latch;
    }
    //sort
    if (nano.rec[positionOffset] == 0 && s_latch) {
        sort[s_mod].record(0);
        sort[s_mod].play(1);
        noiseSort[s_mod].record(0);
        noiseSort[s_mod].play(1);
        0 => s_latch;
    }
}

fun void easing() {
    // easing amount
    0.04 => float increment;
    0.02 => float gateIncrement;

    // check
    for (0 => int i; i < c_num; i++) {
        if (c_vol < ease_c_vol) {
            c_vol + increment => c_vol;
        }
        if (c_vol > ease_c_vol) {
            c_vol - increment => c_vol;
        }
    }

    // sort
    if (s_vol < ease_s_vol) {
        s_vol + increment => s_vol;
    }
    else if (s_vol > ease_s_vol) {
        s_vol - increment => s_vol;
    }

    // lisaCluster
    for (0 => int i; i < lc_num; i++) {
        if (lc_vol[i] < ease_lc_vol[i]) {
            lc_vol[i] + increment => lc_vol[i];
        }
        else if (lc_vol[i] > ease_lc_vol[i]) {
            lc_vol[i] - increment => lc_vol[i];
        }
    }

    // global
    if (globalMix < ease_globalMix) {
        globalMix + increment => globalMix;
        globalMix/127.0 => inputMix;
        1.0 - globalMix/127.0 => noiseMix;
    }
    else if (globalMix > ease_globalMix) {
        globalMix - increment => globalMix;
        globalMix/127.0 => inputMix;
        1.0 - globalMix/127.0 => noiseMix;
    }

    // gate rate
    for (0 => int i; i < g_num; i++) {
        if (g_rate[i] < ease_g_rate[i]) {
            g_rate[i] + gateIncrement => g_rate[i];
        }
        else if (g_rate[i] > ease_g_rate[i]) {
            g_rate[i] - gateIncrement => g_rate[i];
        }
    }
}

// one function to rule them all
fun void updateGains() {
    // check
    for (0 => int i; i < c_num; i++) {
        check[i].gain(c_vol/127.0 * globalGain * inputMix * checkGate[i]);
        noiseCheck[i].gain(c_vol/127.0 * globalGain * noiseMix * noiseCheckGate[i]);
    }

    // reich
    for (0 => int i; i < r_num; i++) {
        reich[i].gain(r_vol/127.0 * globalGain * inputMix * 0.05);
        noiseReich[i].gain(r_vol/127.0 * globalGain * noiseMix * 0.05);
    }

    // sort
    for (0 => int i; i < s_num; i++) {
        sort[i].gain(s_vol/127.0 * globalGain * inputMix);
        noiseSort[i].gain(s_vol/127.0 * globalGain * noiseMix);
    }

    // lisaCluster
    for (0 => int i; i < lc_num; i++) {
        lisaCluster[i].vol(lc_vol[i]/127.0 * globalGain * inputMix);
        noiseLisaCluster[i].vol(lc_vol[i]/127.0 * globalGain * noiseMix);
    }
}

fun void globalParams() {
    if (nano.stop) {
        0.0 => globalGain;
        inputGain.gain(1.0);
        fft.gain(0.0);
    }
    if (nano.play) {
        inputGain.gain(0.0);
        1.0 => globalGain;
        fft.gain(1.0);
    }
    if (nano.slider[5] != ease_g_rate[0]) {
        nano.slider[5] => ease_g_rate[0];
    }
    if (nano.slider[6] != ease_g_rate[1]) {
        nano.slider[6] => ease_g_rate[1];
    }
    if (nano.slider[7] != ease_globalMix) {
        nano.slider[7] => ease_globalMix;
    }
}


fun void allGating(int idx) {
    5.0::second => dur gateMax;
    5.0::second => dur gateTime;
    while (true) {
        Math.pow(g_rate[idx]/127.0, 3) * gateMax + 10::ms => gateTime;
        if (ease_g_rate[idx] != 0) {
            0.0 => checkGate[idx];
            0.0 => noiseCheckGate[idx];
            0.0 => sortGains[idx].gain;
            0.0 => reichGains[idx].gain;
            for (0 => int i; i < lc_num; i++) {
                lisaCluster[i].panVol(idx, 0.0);
                noiseLisaCluster[i].panVol(idx, 0.0);
            }
        }
        gateTime => now;
        if (ease_g_rate[idx] != 0) {
            1.0 => checkGate[idx];
            1.0 => noiseCheckGate[idx];
            1.0 => sortGains[idx].gain;
            1.0 => reichGains[idx].gain;
            for (0 => int i; i < lc_num; i++) {
                lisaCluster[i].panVol(idx, 1.0);
                noiseLisaCluster[i].panVol(idx, 1.0);
            }
        }
        gateTime => now;
    }
}

spork ~ reichWobble();
spork ~ fftWobble();
spork ~ allGating(0);
spork ~ allGating(1);

// run it
while (true) {
    globalParams();
    sortParams();
    reichParams();
    lisaClusterParams();
    easing();
    checkParams();
    globalParams();
    updateGains();
    10::ms => now;
}
