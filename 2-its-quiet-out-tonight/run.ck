// master.ck
// Eric Heep

// communication classes
Machine.add(me.dir() + "/Handshake.ck");
Machine.add(me.dir() + "/HandshakeID.ck");
Machine.add(me.dir() + "/Puck.ck");
Machine.add(me.dir() + "/Motor.ck");

// mir classes
Machine.add(me.dir() + "/Spectral.ck");
Machine.add(me.dir() + "/Subband.ck");
Machine.add(me.dir() + "/Features.ck");
Machine.add(me.dir() + "/CheapRMS.ck");

// midi classes
// Machine.add(me.dir() + "/NanoKontrol2.ck");
// Machine.add(me.dir() + "/Quneo.ck");

// looping classes
Machine.add(me.dir() + "/Phonogene.ck");
Machine.add(me.dir() + "/Sort.ck");

// main program
3.0::second => now;
// Machine.add(me.dir() + "/its-quiet-out-tonight.ck");
Machine.add(me.dir() + "/test-run.ck");
