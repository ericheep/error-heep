// nanoSpeech.ck ~ refactor
// Eric Heep, January 15th 2016

// headphone channel for monitoring, adds another channel
false => int HEADPHONES;

SndBuf input;
Gain phones;

if (HEADPHONES) {
    input => phones => dac.chan(2);
}

input.read(me.dir() + "/apollo11saturnV.wav");

// midi control
NanoKontrol nano;

// LiSaCluster ~~~~~~~~~~~~~~~~~~~~~~
LiSaCluster lc[2];
lc.cap() => int lc_num;
float lc_gain[lc_num];

// LiSaCluster setup
for (int i; i < lc_num; i++) {
    // lc sound chain
    input => lc[i];
    // lc initialize functions
    lc[i].fftSize(1024);
    lc[i].vol(0.0);
    lc[i].numClusters(5);
    lc[i].stepLength(50::ms);
    // alternate gain
    lc[i] => phones;
}

// features for first cluster
lc[0].centroid(1);
lc[0].crest(1);

// features for second cluster
lc[1].hfc(1);
lc[1].subbandCentroids(1);

int lc_vol[lc_num];
int lc_pos[lc_num];
int lc_latch[lc_num];
int lc_state[lc_num];
int lc_pan[lc_num];
float lc_spin[lc_num];

// LiSaCluster controls
fun void lcParams() {
    for (int i; i < lc_num; i++) {
        // active/inactive
        if (nano.top[i] != lc_state[i]) {
            nano.top[i] => lc_state[i];
            // turns on/off gain
            if (lc_state[i]) lc[i].state(1.0);
            else lc[i].state(0.0);
        }
        // gain
        if (nano.slider[i] != lc_vol[i]) {
            nano.slider[i] => lc_vol[i];
            lc[i].vol(lc_vol[i]/127.0);
        }
        // record
        if (nano.bot[i] && lc_latch[i] == 0) {
            lc[i].play(0);
            lc[i].record(1);
            1 => lc_latch[i];
        }
        if (nano.bot[i] == 0 && lc_latch[i]) {
            lc[i].record(0);
            lc[i].play(1);
            0 => lc_latch[i];
        }
        if (nano.knob[i] != lc_pan[i]) {
            nano.knob[i] => lc_pan[i];
            lc_pan[i]/127.0 => lc_spin[i];
        }
    }
}

// LiSaCluster panning
fun void lcSpin(int idx) {
    float mod, pan;
    while (true) {
        if (idx) {
            (mod + lc_spin[idx] * .0001) % 2.0 => mod;
            mod - 1.0 => pan;
        }
        else {
            (mod + lc_spin[idx] * .0001) % 2.0 => mod;
            (mod * -1.0 + 1.0) => pan;
        }
        lc[idx].clusterPan(pan);
        0.1::ms => now;
    }
}

// Reich ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Reich r[2];
Pan2 r_mp[r.size()];
r.cap() => int r_num;

// Reich setup
for (int i; i < r_num; i++) {
    // r sound chain
    input => r[i] => r_mp[i] => dac;
    // r initialize functions
    r[i].gain(0.0);
    // turning down volume of multipan
    r_mp[i].gain(0.0);
    r[i].randomPos(1);
    r[i].voices(16);
    r[i].bi(1);
    r[i].randomPos(1);
    // alternate gain
    r[i] => phones;
}

int r_vol[r_num];
int r_spd[r_num];
int r_latch[r_num];
int r_state[r_num];

// Reich controls
fun void rParams() {
    for (int i; i < r_num; i++) {
        // active/inactive
        if (nano.top[i + lc_num] != r_state[i]) {
            nano.top[i + lc_num] => r_state[i];
            // turns on/off gain
            if (r_state[i]) r_mp[i].gain(1.0);
            else r_mp[i].gain(0.0);
        }
        // speed
        if (nano.knob[i + lc_num] != r_spd[i]) {
            nano.knob[i + lc_num] => r_spd[i];
            r[i].speed(r_spd[i]/127.0 * 2.0);
        }
        // gain
        if (nano.slider[i + lc_num] != r_vol[i]) {
            nano.slider[i + lc_num] => r_vol[i];
            r[i].gain(r_vol[i]/127.0);
        }
        // record
        if (nano.bot[i + lc_num] && r_latch[i] == 0) {
            r[i].play(0);
            r[i].record(1);
            1 => r_latch[i];
        }
        if (nano.bot[i + lc_num] == 0 && r_latch[i]) {
            r[i].record(0);
            r[i].play(1);
            0 => r_latch[i];
        }
    }
}

// Reich panning
fun void rSpin() {
    float pan;
    while (true) {
        (pan + 0.000001) % 2.0 => pan;
        r_mp[0].pan(pan - 1.0);
        r_mp[1].pan((pan - 1.0) * -1.0 + 1.0);
        0.1::ms => now;
    }
}

// main loop
fun void params() {
    <<< "!" >>>;
    while (true) {
        rParams();
        lcParams();
        10::ms => now;
    }
}

// NOTE: maybe incorporate these spin functions into main param functions
// less sporking, easier calc, maybe, like Sort

// automatic panning functions
spork ~ lcSpin(0);
spork ~ lcSpin(1);
params();
