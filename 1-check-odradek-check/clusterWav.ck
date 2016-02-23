// nanoSpeech.ck ~ refactor
// Eric Heep, January 15th 2016

SndBuf input;

input.read(me.dir() + "voice.wav");

// LiSaCluster ~~~~~~~~~~~~~~~~~~~~~~
LiSaCluster lc;

// lc sound chain
input => lc;
// lc initialize functions
lc.fftSize(1024);
lc.vol(1.0);
lc.numClusters(5);
lc.stepLength(83::ms);

// features for first cluster
// lc.centroid(1);
lc.crest(1);
lc.hfc(1);
// lc.subbandCentroids(1);

lc.record(1);
input.samples()::samp => now;
lc.record(0);
<<< "playing" >>>;
lc.play(1);
lc.pan(0.0);
float inc;

now => time start;
now + 1::minute => time end;

while (now < end) {
    (inc + 0.005) % pi => inc;
    lc.pan(Math.sin(inc));
    20::ms => now;
}
