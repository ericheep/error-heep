// Markov.ck

public class Markov {

    0 => int currentRow;

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

    // recursively populates the matrix
    fun void recursiveCombinations(int pos, int element[], int current[], int combinations[][]) {
        if (pos == current.size()) {
            for (0 => int i; i < element.size(); i++) {
                current[i] => combinations[currentRow][i];
            }

            currentRow++;
            return;
        }
        for (int i; i < element.size(); i++) {
            element[i] => current[pos];
            recursiveCombinations(pos + 1, element, current, combinations);
        }
    }

    fun int factorial(int x) {
        if (x <= 1) return 1;
        else return (x * factorial(x - 1));
    }

    //
    fun float[][] generateTransitionMatrix(int inputChain[], int order, int range) {

        inputChain.size() => int length;

        // Math.pow(range, order)$int => int rows;
        Math.pow(range, order)$int => int rows;

        float transitionMatrix[rows][range];
        int combinations[rows][range];
        // <<< transitionMatrix.size(), transitionMatrix[0].size() >>>;

        int element[range];
        int current[range];

        for (0 => int i; i < range; i++) {
            i => element[i];
        }

        int combination[range];
        recursiveCombinations(0, element, current, combinations);
        0 => currentRow;


        for (0 => int i; i < combinations.size(); i++) {
            for (int j; j < range; j++) {
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
            <<< combination[0], combination[1], combination[2], "~", transitionMatrix[i][0], transitionMatrix[i][1], transitionMatrix[i][2] >>>;
        }

        return transitionMatrix;
    }
}

Markov markov;
SinOsc sin => dac;

3 => int range;
3 => int order;

/*
// transistion matrix
float transitionMatrix[rows][range];

for (0 => int i; i < rows; i++) {
    for (0 => int j; j < range; j++) {
        Math.random2f(0.0, 1.0) => transitionMatrix[i][j];
    }
}
*/

[0, 1, 2, 1, 1, 2] @=> int base[];
int chain[base.size()];

// <<< 0, 1, 2, 0, 1, 2, 2 >>>;
// markov.generateChain(chain, transitionMatrix, order, range) @=> chain;
markov.generateTransitionMatrix(base, order, range) @=> float transitionMatrix[][];

while (true) {
    for (0 => int i; i < chain.size(); i++) {
        sin.freq(Std.mtof(chain[i] + 60));
        150::ms => now;
    }
    markov.generateChain(base, transitionMatrix, order, range) @=> chain;
    // <<< chain[0], chain[1], chain[2], chain[3], chain[4] >>>;
}
