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

    // generates all combinations with repititions of a range of numbers as a matrix
    fun float[][] generateCombinations(int order, int range) {

        Math.pow(range, order)$int => int rows;
        int combinations[rows][range];
        int inc[range];
        int recentlyIncremented[range];
        rows * range => int N;

        for (0 => int i; i < N; i++) {
             i => int n;

        }

        /*
        for (0 => int i; i < rows; i++) {
            <<< inc[2], inc[1], inc[0] >>>;
            for (0 => int j; j < range; j++) {
                (inc[j] + 1) % range => inc[j];
                if (recentlyIncremented[j] == 1) {
                    inc[j]++;
                }
            }
        }

        for (0 => int j; j < rows; j++) {

            <<< add2, add, inc >>>;
            (inc + 1) % range => inc;

            if (inc == 0) {
                (add + 1) % range => add;
                if (add == 0) {
                    (add2 + 1) % range => add2;
                }
            }
        }
        */
        // <<< combinations[i][0], combinations[i][1], combinations[i][2] >>>;
    }

    fun float[][] generateTransitionMatrix(int inputChain[], int order, int range) {

        inputChain.size() => int length;
        float transitionMatrix[Math.pow(range, order)$int][range];

        int row;
        [1, 1] @=> int combination[];

        int matches[0];
        // checks if current combination is in input chain
        for (0 => int j; j < length; j++) {
            int matchSum;

            for (0 => int i; i < order; i++) {
                if (inputChain[(length - order + i + j) % length] == combination[i]) {
                    1 +=> matchSum;
                }
            }

            if (matchSum == order) {
               matches << inputChain[j];
            }
        }
        matches.size() => int size;
        for (0 => int j; j < size; j++) {
            1.0/size +=> transitionMatrix[row][matches[j]];
        }
    }
}

Markov markov;
SinOsc sin => dac;

3 => int range;
2 => int order;
Math.pow(range, order)$int => int rows;

markov.generateCombinations(order, range);

/*
// transistion matrix
float transitionMatrix[rows][range];

for (0 => int i; i < rows; i++) {
    for (0 => int j; j < range; j++) {
        Math.random2f(0.0, 1.0) => transitionMatrix[i][j];
    }
}

// original chain, range is the number of
// rows in a first order chain
[0, 1, 2, 1, 0, 1, 0] @=> int chain[];

// markov.generateChain(chain, transitionMatrix, order, range) @=> chain;
markov.generateTransitionMatrix(chain, order, range);

while (true) {
    for (0 => int i; i < chain.size(); i++) {
        sin.freq(Std.mtof(chain[i] + 60));
        150::ms => now;
    }
    markov.generateChain(chain, transitionMatrix, order, range) @=> chain;
}
