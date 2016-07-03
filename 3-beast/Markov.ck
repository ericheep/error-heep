// Markov.ck

public class Markov {

    0 => int currentRow;

    fun int[] generateChain(int inputChain[], float transitionMatrix[][], int order, int range) {
        /* Calculates an output chain based on the input and its probabilities.

        Parameters
        ----------
        inputChain : int array
            input chain that the output will be created from
        transitionMatrix : two dimensional float array
            collection of probabilities
        order : int
            Markov chain order
        range : int
            range of values that can be considered

        Returns
        -------
        outputChain : int array
            output chain
        */

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

    // ~ manually inputting Cartesian Products for now, might figure this out later

    /*
    // three order markov, range of six
    [[ 0 , 0 , 0 ], [ 0 , 0 , 1 ], [ 0 , 0 , 2 ], [ 0 , 0 , 3 ], [ 0 , 0 , 4 ], [ 0 , 0 , 5 ],
    [ 0 , 1 , 0 ], [ 0 , 1 , 1 ], [ 0 , 1 , 2 ], [ 0 , 1 , 3 ], [ 0 , 1 , 4 ], [ 0 , 1 , 5 ],
    [ 0 , 2 , 0 ], [ 0 , 2 , 1 ], [ 0 , 2 , 2 ], [ 0 , 2 , 3 ], [ 0 , 2 , 4 ], [ 0 , 2 , 5 ],
    [ 0 , 3 , 0 ], [ 0 , 3 , 1 ], [ 0 , 3 , 2 ], [ 0 , 3 , 3 ], [ 0 , 3 , 4 ], [ 0 , 3 , 5 ],
    [ 0 , 4 , 0 ], [ 0 , 4 , 1 ], [ 0 , 4 , 2 ], [ 0 , 4 , 3 ], [ 0 , 4 , 4 ], [ 0 , 4 , 5 ],
    [ 0 , 5 , 0 ], [ 0 , 5 , 1 ], [ 0 , 5 , 2 ], [ 0 , 5 , 3 ], [ 0 , 5 , 4 ], [ 0 , 5 , 5 ],
    [ 1 , 0 , 0 ], [ 1 , 0 , 1 ], [ 1 , 0 , 2 ], [ 1 , 0 , 3 ], [ 1 , 0 , 4 ], [ 1 , 0 , 5 ],
    [ 1 , 1 , 0 ], [ 1 , 1 , 1 ], [ 1 , 1 , 2 ], [ 1 , 1 , 3 ], [ 1 , 1 , 4 ], [ 1 , 1 , 5 ],
    [ 1 , 2 , 0 ], [ 1 , 2 , 1 ], [ 1 , 2 , 2 ], [ 1 , 2 , 3 ], [ 1 , 2 , 4 ], [ 1 , 2 , 5 ],
    [ 1 , 3 , 0 ], [ 1 , 3 , 1 ], [ 1 , 3 , 2 ], [ 1 , 3 , 3 ], [ 1 , 3 , 4 ], [ 1 , 3 , 5 ],
    [ 1 , 4 , 0 ], [ 1 , 4 , 1 ], [ 1 , 4 , 2 ], [ 1 , 4 , 3 ], [ 1 , 4 , 4 ], [ 1 , 4 , 5 ],
    [ 1 , 5 , 0 ], [ 1 , 5 , 1 ], [ 1 , 5 , 2 ], [ 1 , 5 , 3 ], [ 1 , 5 , 4 ], [ 1 , 5 , 5 ],
    [ 2 , 0 , 0 ], [ 2 , 0 , 1 ], [ 2 , 0 , 2 ], [ 2 , 0 , 3 ], [ 2 , 0 , 4 ], [ 2 , 0 , 5 ],
    [ 2 , 1 , 0 ], [ 2 , 1 , 1 ], [ 2 , 1 , 2 ], [ 2 , 1 , 3 ], [ 2 , 1 , 4 ], [ 2 , 1 , 5 ],
    [ 2 , 2 , 0 ], [ 2 , 2 , 1 ], [ 2 , 2 , 2 ], [ 2 , 2 , 3 ], [ 2 , 2 , 4 ], [ 2 , 2 , 5 ],
    [ 2 , 3 , 0 ], [ 2 , 3 , 1 ], [ 2 , 3 , 2 ], [ 2 , 3 , 3 ], [ 2 , 3 , 4 ], [ 2 , 3 , 5 ],
    [ 2 , 4 , 0 ], [ 2 , 4 , 1 ], [ 2 , 4 , 2 ], [ 2 , 4 , 3 ], [ 2 , 4 , 4 ], [ 2 , 4 , 5 ],
    [ 2 , 5 , 0 ], [ 2 , 5 , 1 ], [ 2 , 5 , 2 ], [ 2 , 5 , 3 ], [ 2 , 5 , 4 ], [ 2 , 5 , 5 ],
    [ 3 , 0 , 0 ], [ 3 , 0 , 1 ], [ 3 , 0 , 2 ], [ 3 , 0 , 3 ], [ 3 , 0 , 4 ], [ 3 , 0 , 5 ],
    [ 3 , 1 , 0 ], [ 3 , 1 , 1 ], [ 3 , 1 , 2 ], [ 3 , 1 , 3 ], [ 3 , 1 , 4 ], [ 3 , 1 , 5 ],
    [ 3 , 2 , 0 ], [ 3 , 2 , 1 ], [ 3 , 2 , 2 ], [ 3 , 2 , 3 ], [ 3 , 2 , 4 ], [ 3 , 2 , 5 ],
    [ 3 , 3 , 0 ], [ 3 , 3 , 1 ], [ 3 , 3 , 2 ], [ 3 , 3 , 3 ], [ 3 , 3 , 4 ], [ 3 , 3 , 5 ],
    [ 3 , 4 , 0 ], [ 3 , 4 , 1 ], [ 3 , 4 , 2 ], [ 3 , 4 , 3 ], [ 3 , 4 , 4 ], [ 3 , 4 , 5 ],
    [ 3 , 5 , 0 ], [ 3 , 5 , 1 ], [ 3 , 5 , 2 ], [ 3 , 5 , 3 ], [ 3 , 5 , 4 ], [ 3 , 5 , 5 ],
    [ 4 , 0 , 0 ], [ 4 , 0 , 1 ], [ 4 , 0 , 2 ], [ 4 , 0 , 3 ], [ 4 , 0 , 4 ], [ 4 , 0 , 5 ],
    [ 4 , 1 , 0 ], [ 4 , 1 , 1 ], [ 4 , 1 , 2 ], [ 4 , 1 , 3 ], [ 4 , 1 , 4 ], [ 4 , 1 , 5 ],
    [ 4 , 2 , 0 ], [ 4 , 2 , 1 ], [ 4 , 2 , 2 ], [ 4 , 2 , 3 ], [ 4 , 2 , 4 ], [ 4 , 2 , 5 ],
    [ 4 , 3 , 0 ], [ 4 , 3 , 1 ], [ 4 , 3 , 2 ], [ 4 , 3 , 3 ], [ 4 , 3 , 4 ], [ 4 , 3 , 5 ],
    [ 4 , 4 , 0 ], [ 4 , 4 , 1 ], [ 4 , 4 , 2 ], [ 4 , 4 , 3 ], [ 4 , 4 , 4 ], [ 4 , 4 , 5 ],
    [ 4 , 5 , 0 ], [ 4 , 5 , 1 ], [ 4 , 5 , 2 ], [ 4 , 5 , 3 ], [ 4 , 5 , 4 ], [ 4 , 5 , 5 ],
    [ 5 , 0 , 0 ], [ 5 , 0 , 1 ], [ 5 , 0 , 2 ], [ 5 , 0 , 3 ], [ 5 , 0 , 4 ], [ 5 , 0 , 5 ],
    [ 5 , 1 , 0 ], [ 5 , 1 , 1 ], [ 5 , 1 , 2 ], [ 5 , 1 , 3 ], [ 5 , 1 , 4 ], [ 5 , 1 , 5 ],
    [ 5 , 2 , 0 ], [ 5 , 2 , 1 ], [ 5 , 2 , 2 ], [ 5 , 2 , 3 ], [ 5 , 2 , 4 ], [ 5 , 2 , 5 ],
    [ 5 , 3 , 0 ], [ 5 , 3 , 1 ], [ 5 , 3 , 2 ], [ 5 , 3 , 3 ], [ 5 , 3 , 4 ], [ 5 , 3 , 5 ],
    [ 5 , 4 , 0 ], [ 5 , 4 , 1 ], [ 5 , 4 , 2 ], [ 5 , 4 , 3 ], [ 5 , 4 , 4 ], [ 5 , 4 , 5 ],
    [ 5 , 5 , 0 ], [ 5 , 5 , 1 ], [ 5 , 5 , 2 ], [ 5 , 5 , 3 ], [ 5 , 5 , 4 ], [ 5 , 5 , 5 ]] @=> int combinations[][];*/

    // two order markov, range of six
    [[ 0 , 0 ], [ 0 , 1 ], [ 0 , 2 ], [ 0 , 3 ], [ 0 , 4 ], [ 0 , 5 ],
    [ 1 , 0 ], [ 1 , 1 ], [ 1 , 2 ], [ 1 , 3 ], [ 1 , 4 ], [ 1 , 5 ],
    [ 2 , 0 ], [ 2 , 1 ], [ 2 , 2 ], [ 2 , 3 ], [ 2 , 4 ], [ 2 , 5 ],
    [ 3 , 0 ], [ 3 , 1 ], [ 3 , 2 ], [ 3 , 3 ], [ 3 , 4 ], [ 3 , 5 ],
    [ 4 , 0 ], [ 4 , 1 ], [ 4 , 2 ], [ 4 , 3 ], [ 4 , 4 ], [ 4 , 5 ],
    [ 5 , 0 ], [ 5 , 1 ], [ 5 , 2 ], [ 5 , 3 ], [ 5 , 4 ], [ 5 , 5 ]] @=> int combinations[][];

    // generate probabilities from an existing chain
    fun float[][] generateTransitionMatrix(int inputChain[], int order, int range) {
        /* Generates transition matrix from a chain.

        Parameters
        ----------
        inputChain : int array
            input chain that the output will be created from
        order : int
            Markov chain order
        range : int
            range of values that can be considered

        Returns
        -------
        outputChain : int array
            output chain
        */

        inputChain.size() => int length;
        Math.pow(range, order)$int => int rows;

        float transitionMatrix[rows][range];

        int element[range];
        int current[range];

        for (0 => int i; i < range; i++) {
            i => element[i];
        }

        int combination[range];
        0 => currentRow;

        for (0 => int i; i < combinations.size(); i++) {
            for (int j; j < order; j++) {
                combinations[i][j] => combination[j];
            }

            int matches[0];

            // checks if current combination is in input chain
            for (0 => int j; j < length; j++) {
                0 => int matchSum;

                for (0 => int k; k < order; k++) {
                    if (inputChain[(length - order + k + j) % length] == combination[k]) {
                        1 +=> matchSum;
                    }
                }

                if (matchSum == order) {
                   matches << inputChain[j];
                }
            }
            matches.size() => int size;
            for (0 => int j; j < size; j++) {
                1.0/size +=> transitionMatrix[i][matches[j]];
            }
        }

        return transitionMatrix;
    }
}

/*
Markov markov;
SinOsc sin => dac;

6 => int range;
2 => int order;

[0, 1, 5, 1, 2, 1, 2, 0, 2, 1, 2, 3, 2] @=> int base[];
base @=> int chain[];

// markov.generateChain(chain, transitionMatrix, order, range) @=> chain;
markov.generateTransitionMatrix(base, order, range) @=> float transitionMatrix[][];

while (true) {
    for (0 => int i; i < chain.size(); i++) {
        sin.freq(Std.mtof(chain[i] + 60));
        50::ms => now;
    }
    markov.generateChain(chain, transitionMatrix, order, range) @=> chain;
    // <<< chain[0], chain[1], chain[2], chain[3], chain[4] >>>;
}
*/
