// Markov.ck

public class Markov {

    fun int[] generateChain(int inputChain[], float transitionMatrix[][], int order, int range) {

        inputChain.size() => int length;
        int outputChain[length];

        // a new link for length of the array
        for (0 => int j; j < length; j++) {
            int row;

            // finds row index
            for (0 => int i; i < order; i++) {
               inputChain[(length - order + i + j) % length] => int element;
               (Math.pow(range, order - i - 1) * element) $ int +=> row;
            }


            // finds range of values
            float sum;
            for (0 => int i; i < range; i++) {
                transitionMatrix[row][i] +=> sum;
            }

            Math.random2f(0.0, sum) => float randomValue;

            // finds our next link for the chain
            0.0 => sum;
            for (0 => int i; i < range; i++) {
                transitionMatrix[row][i] +=> sum;
                if (randomValue < sum) {
                    i => outputChain[j];
                    break;
                }
            }
        }

        return outputChain;
    }

    fun float[][] generateTransistionMarix(int inputChain[], int order, int range) {

        inputChain.size() => int length;
        float transitionMatrix[Math.pow(range, order)$int][range];

    }
}

Markov markov;
SinOsc sin => dac;

12 => int range;
5 => int order;

// transistion matrix
float transitionMatrix[Math.pow(range, order)$int][range];

for (0 => int i; i < transitionMatrix.size(); i++) {
    for (0 => int j; j < range; j++) {
        Math.random2f(0.0, 1.0) => transitionMatrix[i][j];
    }
}

// original chain, range is the number of
// rows in a first order chain
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] @=> int chain[];

markov.generateChain(chain, transitionMatrix, order, range) @=> chain;

while (true) {
    for (0 => int i; i < chain.size(); i++) {
        sin.freq(Std.mtof(chain[i] + 60));
        150::ms => now;
    }
    markov.generateChain(chain, transitionMatrix, order, range) @=> chain;
}
