import 'dart:math';

// Abramowitz and Stegun approximation of erf(x)
double erf(double x) {
  final double t = 1.0 / (1.0 + 0.5 * x.abs());
  final double tau =
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
                                                                            t *
                                                                                0.17087277)))))))),
      );

  return x >= 0 ? 1 - tau : tau - 1;
}

double normalCDF(double x) {
  return 0.5 * (1 + erf(x / sqrt(2)));
}

double inverseNormal(double p) {
  if (p <= 0 || p >= 1) {
    throw ArgumentError('p must be between 0 and 1, exclusive.');
  }

  double low = -10;
  double high = 10;

  for (int i = 0; i < 100; i++) {
    final double mid = (low + high) / 2;
    if (normalCDF(mid) < p) {
      low = mid;
    } else {
      high = mid;
    }
  }

  return (low + high) / 2;
}

// -----------------------------
// Basic descriptive statistics
// -----------------------------

double mean(List<double> values) {
  if (values.isEmpty) {
    throw ArgumentError('Cannot calculate mean of empty list.');
  }

  return values.reduce((a, b) => a + b) / values.length;
}

double sampleStdDev(List<double> values) {
  if (values.length < 2) {
    throw ArgumentError('At least 2 values are required for standard deviation.');
  }

  final double m = mean(values);
  final double sumSquares =
      values.map((x) => pow(x - m, 2).toDouble()).reduce((a, b) => a + b);

  return sqrt(sumSquares / (values.length - 1));
}

double pooledStdDev(double s1, double s2) {
  return sqrt((pow(s1, 2) + pow(s2, 2)) / 2);
}

double effectSizeFromMeans({
  required double mean1,
  required double mean2,
  required double pooledSd,
}) {
  if (pooledSd <= 0) {
    throw ArgumentError('Pooled standard deviation must be greater than 0.');
  }

  return (mean2 - mean1).abs() / pooledSd;
}

// -----------------------------
// Sample size formulas
// -----------------------------

double oneSampleContinuousN({
  required double mu0,
  required double mu1,
  required double sigma,
  required double alpha,
  required double power,
}) {
  final double diff = (mu1 - mu0).abs();

  if (diff <= 0) {
    throw ArgumentError('Mean difference must be greater than 0.');
  }

  if (sigma <= 0) {
    throw ArgumentError('Standard deviation must be greater than 0.');
  }

  final double zAlpha = inverseNormal(1 - alpha / 2);
  final double zPower = inverseNormal(power);

  return pow(sigma * (zAlpha + zPower) / diff, 2).toDouble();
}

double twoSampleContinuousNPerGroup({
  required double mean1,
  required double mean2,
  required double sigma,
  required double alpha,
  required double power,
}) {
  final double diff = (mean2 - mean1).abs();

  if (diff <= 0) {
    throw ArgumentError('Mean difference must be greater than 0.');
  }

  if (sigma <= 0) {
    throw ArgumentError('Standard deviation must be greater than 0.');
  }

  final double zAlpha = inverseNormal(1 - alpha / 2);
  final double zPower = inverseNormal(power);

  return 2 * pow(sigma * (zAlpha + zPower) / diff, 2).toDouble();
}

double twoSampleContinuousNPerGroupFromEffectSize({
  required double effectSize,
  required double alpha,
  required double power,
}) {
  if (effectSize <= 0) {
    throw ArgumentError('Effect size must be greater than 0.');
  }

  final double zAlpha = inverseNormal(1 - alpha / 2);
  final double zPower = inverseNormal(power);

  return 2 * pow((zAlpha + zPower) / effectSize, 2).toDouble();
}

double dichotomousTwoGroupNPerGroup({
  required double p1,
  required double p2,
  required double alpha,
  required double power,
}) {
  if (p1 <= 0 || p1 >= 1 || p2 <= 0 || p2 >= 1) {
    throw ArgumentError('Proportions must be between 0 and 1.');
  }

  final double delta = (p2 - p1).abs();

  if (delta <= 0) {
    throw ArgumentError('Difference between proportions must be greater than 0.');
  }

  final double zAlpha = inverseNormal(1 - alpha / 2);
  final double zPower = inverseNormal(power);

  final double pbar = (p1 + p2) / 2;
  final double qbar = 1 - pbar;

  final double numerator =
      zAlpha * sqrt(2 * pbar * qbar) +
      zPower * sqrt(p1 * (1 - p1) + p2 * (1 - p2));

  return pow(numerator / delta, 2).toDouble();
}