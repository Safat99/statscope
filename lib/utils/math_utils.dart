import 'dart:math';

// Approximation of error function
double erf(double x) {
  // Abramowitz and Stegun approximation
  double t = 1.0 / (1.0 + 0.5 * x.abs());
  double tau =
      t *
      exp(
        -x * x -
            1.26551223 +
            t *
                (1.00002368 +
                    t *
                        (0.37409196 +
                            t *
                                (0.09678418 +
                                    t *
                                        (-0.18628806 +
                                            t *
                                                (0.27886807 +
                                                    t *
                                                        (-1.13520398 +
                                                            t *
                                                                (1.48851587 +
                                                                    t *
                                                                        (-0.82215223 +
                                                                            t * 0.17087277)))))))),
      );
  return x >= 0 ? 1 - tau : tau - 1;
}

// Normal CDF
double normalCDF(double x) {
  return 0.5 * (1 + erf(x / sqrt(2)));
}

// Approx inverse normal (simple)
double inverseNormal(double p) {
  // basic approximation using binary search
  double low = -10, high = 10;
  for (int i = 0; i < 100; i++) {
    double mid = (low + high) / 2;
    if (normalCDF(mid) < p) {
      low = mid;
    } else {
      high = mid;
    }
  }
  return (low + high) / 2;
}
