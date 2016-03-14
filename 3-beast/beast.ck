// Eric Heep
// beast.ck

// serial
Handshake h;
0.5::second => now;
h.talk.init();

// number of solenoids
3 => int NUM_SOLENOIDS;

// analyze
Analyze analyze[NUM_SOLENOIDS];

// behavior
Actuate solenoid[NUM_SOLENOIDS];
Markov markov[NUM_SOLENOIDS];
int activated[NUM_SOLENOIDS];
int wait[NUM_SOLENOIDS];
int endWait[NUM_SOLENOIDS];

// sound chain
Gain input[NUM_SOLENOIDS];

for (int i; i < NUM_SOLENOIDS; i++) {
    adc.chan(i) => input[i] => dac;;
    input[i] => analyze[i];
    analyze[i].setPole(0.999);
    solenoid[i].init(i);

    // wait
    0 => activated[i];
    0 => wait[i];
    0 => endWait[i];
}



// initial state
fun void meditating(int idx) {
    14 => int risingVelocity;
    12 => int sputterVelocity;
    40 => int maxVelocity;
    idx * 70::ms => dur separationDuration;
    2::second => dur waitDuration;
    0.08 => float sputterChance;

    separationDuration => now;
    while (!activated[idx]) {
        risingVelocity++;
        Std.clamp(risingVelocity, 0, maxVelocity) => risingVelocity;
        solenoid[idx].hit(risingVelocity);
        if (Math.random2f(0.0, 1.0) < sputterChance) {
            spork ~ sputter(idx, sputterVelocity, waitDuration);
        }
        waitDuration => now;
    }
}

// kill it for messing up
fun void dying(int idx) {
    1 => float decibelThreshold;
    150::ms => dur originalWaitTime;
    originalWaitTime => dur waitTime;
    700::ms => dur endTime;
    3::ms => dur incrementTime;
    analyze[idx].setPole(0.99);
    70 => int fallingVelocity;

    while (waitTime < endTime && fallingVelocity > 0) {
        if (analyze[idx].decibel() < decibelThreshold) {
            waitTime + incrementTime => waitTime;
        }
        else if (analyze[idx].decibel() > decibelThreshold) {
            if (waitTime > originalWaitTime) {
                waitTime - incrementTime => waitTime;
            }
        }
        <<< waitTime/ms, idx, analyze[idx].decibel() >>>;
        solenoid[idx].hit(fallingVelocity);
        waitTime => now;
        fallingVelocity--;
    }
}

// start it up
fun void initialPlugIn(int idx) {
    5 => float decibelThreshold;
    while (analyze[idx].decibel() < decibelThreshold ){
        1::samp => now;
    }
    <<< idx "activated", "" >>>;
    1 => activated[idx];
}

// random sputters, for color
fun void sputter(int idx, int sputterVelocity, dur waitDuration) {
    Math.random2(0, 1) => int choice;
    dur sputterDuration;

    if (choice == 0) {
        waitDuration/16.0 => sputterDuration;
    }
    else {
        waitDuration/8.0 => sputterDuration;
    }

    Math.random2(4, 10)::ms => dur sputterIncrement;
    now => time start;
    while (now < start + waitDuration) {
        if (choice == 0) {
            sputterDuration + sputterIncrement => sputterDuration;
            solenoid[idx].hit(sputterVelocity);
            sputterDuration => now;
        }
        if (choice == 1) {
            sputterDuration - sputterIncrement => sputterDuration;
            if (sputterDuration > 0::samp) {
                solenoid[idx].hit(sputterVelocity);
                sputterDuration => now;
            }
            else {
                solenoid[idx].hit(sputterVelocity);
                10::ms => now;
            }
        }

    }
}

// plugged in state
fun void genetic(int idx) {
    while (true) {
        Math.random2f(6.0, 11.5)::ms => dur separationDuration;
        Math.random2f(2.0, 4.0)::second => dur waitDuration;
        now => time start;
        while (now < start + waitDuration) {
            solenoid[idx].hit(5);
            separationDuration => now;
        }
    }
}

// wake it up with trs, should be uplugged at this point
fun void wake(int idx) {
    analyze[idx].setPole(0.99);

    [0.03125, 0.10, 0.0625, 0.125, 0.16666, 0.20, 0.25, 0.33333] @=> float subdivisions[];

    8 => int fillerSize;
    16 => int trainSize;
    32 => int rhythmSize;
    0 => int risingVelocity;
    0.0::samp => dur measureLength;


    10.0 => float decibelOverThreshold;
    4.0 => float decibelUnderThreshold;

    int ctr;
    int vel;
    dur trainDurations[0];
    dur rhythmDurations[0];
    float rhythms[0];

    while (ctr < fillerSize + trainSize + rhythmSize) {

        ctr => risingVelocity;
        now => time start;

        // when db goves over
        analyze[idx].decibelOver(decibelOverThreshold);
        100::ms => now;

        // solenoid matching
        if (ctr != trainSize + fillerSize) {
            solenoid[idx].hit(risingVelocity);
        }
        else {
            solenoid[idx].hit(127);
        }

        // when db drops under
        analyze[idx].decibelUnder(decibelUnderThreshold);
        now - start => dur length;

        // counts
        ctr++;

        if (ctr > fillerSize && ctr < trainSize + fillerSize) {
            trainDurations << length;
            // <<< idx, "training measure, vel:", risingVelocity, "length", length/second, trainDurations.size() >>>;
        }

        if (ctr > trainSize + fillerSize) {
            rhythmDurations << length;
            // <<< idx, "training rhythms, vel:", risingVelocity, "length", length/second, rhythmDurations.size() >>>;
            rhythmDurations << length;
        }

        if (ctr == trainSize + fillerSize) {
            dur sum;
            for (0 => int i; i < trainSize; i++) {
                trainDurations[i] +=> sum;
            }
            sum/trainSize * 4 => measureLength;
            <<< idx, "measure trained at", measureLength/second, "seconds" >>>;
        }
    }

    <<< idx, "rhythms trained", "" >>>;

    for (0 => int i; i < rhythmDurations.size(); i++) {
        for (0 => int j; j < subdivisions.size() - 1; j++) {
            subdivisions[j] * measureLength => dur lower;
            subdivisions[j + 1] * measureLength => dur upper;

            // quantizing the inputted rhythms
            if (rhythmDurations[0] < lower) {
                rhythms << subdivisions[j];
            }

            if (rhythmDurations[i] > lower && rhythmDurations[i] < upper) {
                rhythms << subdivisions[j];
            }

            if (rhythmDurations[i] > measureLength) {
                rhythms << subdivisions[j + 1];
            }
        }
    }

    for (0 => int i; i < rhythms.size(); i++) {
        if (risingVelocity > 34) {
            risingVelocity--;
        }
        solenoid[idx].hit(risingVelocity);
        rhythms[i] * measureLength => now;
    }

    /*
    33 => risingVelocity;

    Math.random2f(1.0, 1.5)::second => measureLength;

    for (int i; i < 32; i++) {
        rhythms << subdivisions[Math.random2(0, subdivisions.size() - 1)];
    }
    */

    // markov section
    2 => int order;
    subdivisions.size() => int range;

    // initial chain
    getIndices(rhythms, subdivisions) @=> int indices[];

    // developing chain
    markov[idx].generateTransitionMatrix(indices, order, range) @=> float transitionMatrix[][];
    markov[idx].generateChain(indices, transitionMatrix, order, range) @=> int chain[];

    1.0 => float speed;
    int inc;

    <<< idx, "markov degradation", "" >>>;

    while (inc < 80) {
        if (risingVelocity > 10) {
            risingVelocity--;
        }
        markov[idx].generateTransitionMatrix(indices, order, range) @=> float transitionMatrix[][];
        markov[idx].generateChain(chain, transitionMatrix, order, range) @=> int chain[];

        for (0 => int i; i < rhythmSize; i++) {
            if (measureLength > 1.0::second) {
                measureLength - 1::ms => measureLength;
            }
            else if (measureLength < 1.0::second) {
                measureLength + 1::ms => measureLength;

            }
            if (speed > 0.2) {
                speed - 0.002 => speed;
            }
            rhythms[chain[i]] * speed * measureLength => now;
            solenoid[idx].hit(risingVelocity);
        }
        inc++;
    }

    1 => wait[idx];
    <<< idx, "markov Wait", wait[0], wait[1], wait[2], "" >>>;
    while (wait[0] == 0 || wait[1] == 0 ||  wait[2] == 0) {
        1::samp => now;
    }

    0.4 => speed;
    1.0::second => measureLength;

    <<< idx, "markov converge", "", risingVelocity >>>;
    now => time start;
    while (now < start + 1::minute) {
        risingVelocity++;
        for (0 => int i; i < rhythmSize; i++) {
            rhythms[chain[i]] * measureLength * speed => now;
            solenoid[idx].hit(risingVelocity);
        }
    }
}

fun int[] getIndices(float rhythms[], float subdivisions[]) {
    int indices[rhythms.size()];
    for (0 => int i; i < rhythms.size(); i++) {
        for (0 => int j; j < subdivisions.size(); j++) {
            if(rhythms[i] == subdivisions[j]) {
                j => indices[i];
            }
        }
    }
    return indices;
}

fun void calm(int idx) {
    <<< idx, "calm", "" >>>;
    Math.random2f(6.0, 11.5)::ms => dur separationDuration;
    Math.random2f(2.0, 4.0)::second => dur waitDuration;
    1.0::minute => dur calmDuration;
    now => time start;
    while( now < start + calmDuration) {
        now => time innerStart;
        while (now < innerStart + waitDuration) {
            solenoid[idx].hit(5);
            separationDuration => now;
        }
    }
    1 => endWait[idx];
    while (endWait[0] == 0 || endWait[1] == 0 || endWait[2] || 0) {
        1::samp => now;
    }
    25::second => now;
    idx * 70::ms => now;
    solenoid[idx].hit(40);
}

// main program, sporkable
fun void life(int idx) {
    spork ~ initialPlugIn(idx);
    meditating(idx);
    // genetic(idx);
    dying(idx);
    wake(idx);
    calm(idx);
}

fun void decibelLevels() {
    while (true) {
        //<<< analyze[0].decibel(), analyze[1].decibel(), analyze[2].decibel() >>>;
        10::ms => now;
    }
}

spork ~ decibelLevels();

// main program, three concurrent lives
for (int i; i < NUM_SOLENOIDS; i++) {
    spork ~ life(i);
}

while (true) {
    1::second => now;
}
