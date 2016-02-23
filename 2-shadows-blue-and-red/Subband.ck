// Subband.ck
// Eric Heep

public class Subband {

    // subband analysis
    fun float[] filterBanks(float X[], float filts[], float sr, int N) {

        float banks[filts.size() - 1];
        N/2 + 1 => int bins;

        for (int i; i < bins; i++) {
            sr/N * i => float frq;
            for (int j; j < filts.cap() - 1; j++) {
                if (filts[j] < frq && filts[j + 1] > frq) {
                    X[i] +=> banks[j];
                }
            }
        }

        return banks;
    }

    // subband centroids
    fun float[] subbandCentroid(float X[], float filts[], int N, float sr) {

        float prod[filts.cap() - 1];
        float sum[filts.cap() - 1];
        float centroid[filts.cap() - 1];

        X.cap() => int bins;

        for (int i; i < bins; i++) {
            sr/N * i => float frq;
            for (int j; j < filts.cap() - 1; j++) {
                if (filts[j] < frq && filts[j + 1] > frq) {
                    X[i] * frq +=> prod[j];
                    X[i] +=> sum[j];
                }
            }
        }

        for (int i; i < filts.cap() - 1; i++) {
            if (prod[i] != 0 && sum[i] != 0) {
                prod[i]/sum[i] => centroid[i];
            }
            else {
                0 => centroid[i];
            }
        }

        return centroid;
    }
}
