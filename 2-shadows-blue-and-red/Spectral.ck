// Spectral.ck
// Eric Heep & Daniel Reyes

public class Spectral {

    // spectral centroid
    fun float centroid(float X[], float sr, int fft_size) {

        // array for our bin frequencies
        float fft_frqs[fft_size/2 + 1];

        // finds center bin frequencies
        for (int i; i < fft_frqs.cap(); i++) {
            sr/fft_size * i => fft_frqs[i];
        }

        float den;
        float power[X.cap()];
        for (int i; i < X.cap(); i++) {
            X[i] * X[i] => power[i];
            power[i] +=> den;
        }

        float num;
        for (int i; i < X.cap(); i++) {
            fft_frqs[i] * power[i] +=> num;
        }

        return num/den;
    }

    // spectral spread
    fun float spread(float X[], float sr, int fft_size) {

        // required centroid for spread
        centroid(X, sr, fft_size) => float cent;

        // array for our bin frequencies
        float fft_frqs[fft_size/2 + 1];

        // finds center bin frequencies
        for (int i; i < fft_frqs.cap(); i++) {
            sr/fft_size * i => fft_frqs[i];
        }

        float num, den;
        float power[X.cap()];
        float square[X.cap()];

        for(int i; i < X.cap(); i++) {
            X[i] * X[i] => power[i];
            Math.pow(fft_frqs[i] - cent, 2) => square[i];
            power[i] * square[i] +=> num;
            power[i] +=> den;
        }
        return Math.sqrt(num/den);
    }

    fun float geometricMean (float bins[]) {
        1.0 => float product;
        for (int i; i < bins.size(); i++) {
            if (bins[i] != 0.0) {
                bins[i] *=> product;
            }
        }
        return Math.pow(product, 1.0/bins.size());
    }

    fun float arithmeticMean( float bins[]) {
        0.0 => float sum;
        for (int i; i < bins.size(); i++) {
            bins[i] +=> sum;
        }
        return sum/bins.size();
    }

    fun float flatness (float bins[]) {
        // power stuff
        for (int i; i < bins.size(); i++) {
            bins[i] * bins[i] => bins[i];
        }
        return geometricMean(bins)/arithmeticMean(bins);
    }

    // high-frequency content
    fun float hfc(float X[]) {
        float out;
        for(int k; k < X.cap(); k++){
            X[k] * k +=> out;
        }
        return out;
    }

    // spectral crest factor
    fun float spectralCrest(float x[]){
        float max, sum;
        for (int j; j < x.cap(); j++) {
            if (x[j] >= max) {
                x[j] => max;
            }
            x[j] +=> sum;
        }
        return max / sum;
    }
}
