// Markov.ck

public class Markov {

    fun void generateChain(int inputChain[], float transitionMatrix[][], int order) {

        int holder[order];
        inputChain.size() => int length;

        // grab our two inputs
        for (0 => int i; i < order; i++) {
            inputChain[(length - order + i) % length] => holder[i];
        }

        // works if order is 2, but what if 3?
        <<< holder[0] * order, holder[1] >>>;

        for (0 => int i; i < transitionMatrix.size(); i++) {
        }
    }
}


Markov markov;

// transistion matrix
[[0.3, 0.4, 0.9],
 [0.2, 0.5, 0.2],
 [0.5, 0.3, 0.8],
 [0.5, 0.3, 0.8]] @=> float transitionMatrix[][];

 // original chain, range is the number of
 // rows in a first order chain
 [0, 1, 1, 0, 1] @=> int chain[];

markov.generateChain(chain, transitionMatrix, 2);
