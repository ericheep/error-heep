// check-odradek-check.ck
// Eric Heep, March 10th 2016

// set number of channels
2 => int NUM_CHANNELS;

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
adc => Gain input;


// ~ Reich ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Reich reich;

// reich sound chain
input => reich => dac;
// reich initialize functions
reich.gain(0.0);
reich.randomPos(1);
reich.voices(32);
reich.bi(1);
reich.randomPos(1);

int r_vol;
int r_spd;
int r_latch;
int r_state;


// ~ Sort ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sort sort;
Pan2 panSort;

// sort sound chain
input => sort => panSort => dac;
sort.stepDuration(50::ms);

float s_vol;
int s_state;
int s_latch;
int s_pan;
float s_mod;
float s_spin;

float ease_s_vol;


// ~ LiSaCluster ~~~~~~~~~~~~~~~~~~~~~~~
LiSaCluster2 lisaCluster[2];
lisaCluster.size() => int lc_num;

// LiSaCluster setup
for (0 => int i; i < lc_num; i++) {
    // lisaCluster sound chain
    input => lisaCluster[i];
    // lisaCluster initialize functions
    lisaCluster[i].fftSize(1024);
    lisaCluster[i].gain(0.0);
    lisaCluster[i].numClusters(2);
}

// features for first cluster
lisaCluster[0].centroid(1);
lisaCluster[0].crest(1);

// features for second cluster
lisaCluster[1].hfc(1);
lisaCluster[1].subbandCentroids(1);

float lc_vol[lc_num];
float ease_lc_vol[lc_num];
int lc_latch[lc_num];
int lc_state[lc_num];
int lc_pan[lc_num];
int lc_cluster[lc_num];


// ~ FFTNoise ~~~~~~~~~~~~~~~~~~~~~~~~~~
input => FFTNoise fft => Pan2 fftPan;

int fft_vol;
int fft_state;
int fft_pan;
float fft_chance;


// Reich controls
fun void reichParams() {
    1 => int positionOffset;
    // active/inactive
    if (nano.mute[positionOffset] != r_state) {
        nano.mute[positionOffset] => r_state;
        // turns on/off gain
        if (r_state) reich.gain(r_vol);
        else reich.gain(0.0);
    }
    // speed
    if (nano.knob[positionOffset] != r_spd) {
        nano.knob[positionOffset] => r_spd;
        reich.speed(r_spd/127.0 * 2.0);
    }
    // gain
    if (nano.slider[positionOffset] != r_vol) {
        nano.slider[positionOffset] => r_vol;
        reich.gain(r_vol/127.0);
    }
    // record
    if (nano.rec[positionOffset] && r_latch == 0) {
        reich.play(0);
        reich.record(1);
        1 => r_latch;
    }
    if (nano.rec[positionOffset] == 0 && r_latch) {
        reich.record(0);
        reich.play(1);
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

// LiSaCluster controls
fun void lisaClusterParams() {
    3 => int positionOffset;
    [50.0, 100.0] @=> float stepLengths[];

    for (0 => int i; i < lc_num; i++) {
        // active/inactive
        if (nano.mute[i + positionOffset] != lc_state[i]) {
            nano.mute[i + positionOffset] => lc_state[i];
            // turns on/off gain
            if (lc_state[i]) lisaCluster[i].gain(lc_vol[i]);
            else lisaCluster[i].gain(0.0);
        }
        // gain
        if (nano.slider[i + positionOffset] != ease_lc_vol[i]) {
            nano.slider[i + positionOffset] => ease_lc_vol[i];
            lisaCluster[i].vol(lc_vol[i]/127.0);
            // <<< i, lc_vol[i]/127.0 >>>;
        }

        if (nano.knob[i + positionOffset] != lc_cluster[i]) {
            nano.knob[i + positionOffset] => lc_cluster[i];
            lisaCluster[i].vol(lc_cluster[i]/127.0);
        }
        // record
        if (nano.rec[i + positionOffset] && lc_latch[i] == 0) {
            lisaCluster[i].stepLength(Math.random2f(stepLengths[0], stepLengths[1])::ms);
            lisaCluster[i].play(0);
            lisaCluster[i].record(1);
            1 => lc_latch[i];
        }
        if (nano.rec[i + positionOffset] == 0 && lc_latch[i]) {
            lisaCluster[i].record(0);
            lisaCluster[i].play(1);
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
        if (s_state) sort.gain(s_vol);
        else sort.gain(0.0);
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
        sort.play(0);
        sort.record(1);
        1 => s_latch;
    }
    if (nano.rec[positionOffset] == 0 && s_latch) {
        sort.record(0);
        sort.play(1);
        0 => s_latch;
    }
    // spin
    /*if (i == 0 && s_pan[i] != 0.0) {
        (s_mod[i] + s_spin[i]) % 1.0 => s_mod[i];
        s_mp[i].pan(s_mod[i] * 2.0 - 1.0);
    }
    else if (i == 1 && s_pan[i] != 0.0) {
        (s_mod[i] + s_spin[i]) % 1.0 => s_mod[i];
        s_mp[i].pan((s_mod[i] * -1.0 + 1.0) * 2.0 - 1.0);
    }*/
}

fun void easing() {
    0.03 => float increment;
    if (s_vol < ease_s_vol) {
        s_vol + increment => s_vol;
        sort.gain(s_vol/127.0);
    }
    else if (s_vol > ease_s_vol) {
        s_vol - increment => s_vol;
        sort.gain(s_vol/127.0);
    }

    for (0 => int i; i < lc_num; i++) {
        if (lc_vol[i] < ease_lc_vol[i]) {
            lc_vol[i] + increment => lc_vol[i];
            lisaCluster[i].gain(lc_vol[i]/127.0);
        }
        else if (lc_vol[i] > ease_lc_vol[i]) {
            lc_vol[i] - increment => lc_vol[i];
            lisaCluster[i].gain(lc_vol[i]/127.0);
        }
    }
}

/*
// FFTNoise controls
fun void fftParams() {
    // active/inactive
    if (n.top[6] != fn_state) {
        n.top[6] => fn_state;
        // turns on/off gain
        if (fn_state) fn_mp.vol(1.0);
        else fn_mp.vol(0.0);
    }
    // gain
    if (n.slider[6] != fn_vol) {
        n.slider[6] => fn_vol;
        fn.gain(fn_vol/127.0);
        if (fn_vol == 0) fn.listen(0);
        else fn.listen(1);
    }
    if (n.knob[6] != fn_pan) {
        n.knob[6] => fn_pan;
        fn_pan/127.0 => fn_chance;

    }
}

// FTTNoise panning
fun void fftSpin() {
    float pan;
    while (true) {
        Math.random2f(0.0, 1.0) => pan;
        if (fn_chance > Math.random2f(0.0, 1.0)) {
            fn_mp.pan(pan * 2.0 - 1.0);
        }
        (500 * (fn_chance * -1.0 + 1.0))::ms + 100::ms => now;
    }
}

// Gate controls
fun void gParams() {
    // active/inactive
    if (n.top[7] != g_state) {
        n.top[7] => g_state;
        // turns on/off gain
        if (g_state) g_mp.vol(1.0);
        else g_mp.vol(0.0);
    }
    // gain
    if (n.slider[7] != g_vol) {
        n.slider[7] => g_vol;
        g.gain(g_vol/127.0);
    }
    if (n.knob[7] != g_pan) {
        n.knob[7] => g_pan;
        if (g_pan == 0) {
            g_mp.pan(0.0);
        }
        g_pan/127.0 => g_spin;
    }
}

// Gate panning
fun void gSpin() {
    float pan;
    while (true) {
        if (g_spin){
            (g_spin * .001 + pan) % 1.0 => pan;
            g_mp.pan(pan * 2.0 - 1.0);
        }
        1::ms => now;
    }
}
*/

spork ~ reichWobble();
// spork ~ fnSpin();
// spork ~ gSpin();
// spork ~ hereWeGo();


while (true) {
    sortParams();
    reichParams();
    lisaClusterParams();
    easing();
    // fftParams();
    // gParams();
    // mParams();
    10::ms => now;
}
