import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/math_utils.dart';

class GraphWidget extends StatelessWidget {
  final double alpha;
  final double effectSize;
  final double? nullMean;
  final double? altMean;
  final double standardDeviation;

  const GraphWidget({
    super.key,
    required this.alpha,
    required this.effectSize,
    this.nullMean,
    this.altMean,
    this.standardDeviation = 1,
  });

  @override
  Widget build(BuildContext context) {
    final h0Mean = nullMean ?? 0;
    final h1Mean = altMean ?? effectSize;
    final stdDev = standardDeviation;
    const minX = -4.0;
    const maxX = 7.0;
    const minY = 0.0;
    const maxY = 0.8;
    const leftAxisWidth = 42.0;
    final threshold = h0Mean + stdDev * inverseNormal(1 - alpha);

    List<FlSpot> nullLeft = [];
    List<FlSpot> nullRight = [];
    List<FlSpot> altLeft = [];
    List<FlSpot> altRight = [];

    for (double x = minX; x <= maxX; x += 0.05) {
      double yNull = _pdf(x, h0Mean, stdDev);
      double yAlt = _pdf(x, h1Mean, stdDev);

      if (x <= threshold) {
        nullLeft.add(FlSpot(x, yNull));
        altLeft.add(FlSpot(x, yAlt));
      } else {
        nullRight.add(FlSpot(x, yNull));
        altRight.add(FlSpot(x, yAlt));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //  TITLE
        const SizedBox(height: 6),
        FittedBox(
          child: const Text(
            "Sampling Distributions (H₀ vs H₁)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 10),

        // FIXED GRAPH HEIGHT (IMPORTANT)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: SizedBox(
            height: 280,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const bottomAxisHeight = 30.0;
                const regionLabelWidth = 98.0;
                const curveLabelWidth = 28.0;
                final plotWidth = max(
                  1.0,
                  constraints.maxWidth - leftAxisWidth,
                );
                final plotHeight = max(
                  1.0,
                  constraints.maxHeight - bottomAxisHeight,
                );
                final thresholdPosition = _xToPixel(
                  threshold,
                  minX,
                  maxX,
                  leftAxisWidth,
                  plotWidth,
                );
                final acceptLabelX = max(
                  leftAxisWidth + 8,
                  thresholdPosition - 104,
                );
                final rejectLabelX = min(
                  constraints.maxWidth - 72,
                  thresholdPosition + 10,
                );
                final h0PeakY = _pdf(h0Mean, h0Mean, stdDev);
                final h1PeakY = _pdf(h1Mean, h1Mean, stdDev);
                final h0LabelX = _clampDouble(
                  _xToPixel(h0Mean, minX, maxX, leftAxisWidth, plotWidth) -
                      curveLabelWidth / 2,
                  leftAxisWidth + 4,
                  constraints.maxWidth - curveLabelWidth,
                );
                final h1LabelX = _clampDouble(
                  _xToPixel(h1Mean, minX, maxX, leftAxisWidth, plotWidth) -
                      curveLabelWidth / 2,
                  leftAxisWidth + 4,
                  constraints.maxWidth - curveLabelWidth,
                );
                final h0LabelY = _clampDouble(
                  _yToPixel(
                        min(maxY * 0.92, h0PeakY + 0.04),
                        minY,
                        maxY,
                        plotHeight,
                      ) -
                      18,
                  4,
                  plotHeight - 22,
                );
                final h1LabelY = _clampDouble(
                  _yToPixel(
                        min(maxY * 0.92, h1PeakY + 0.04),
                        minY,
                        maxY,
                        plotHeight,
                      ) -
                      18,
                  4,
                  plotHeight - 22,
                );
                final falsePositiveX = _clampDouble(
                  threshold + 0.38 * stdDev,
                  minX,
                  maxX,
                );
                final falseNegativeX = threshold < h1Mean
                    ? _clampDouble(threshold - 0.45 * stdDev, minX, maxX)
                    : _clampDouble((h1Mean + threshold) / 2, minX, maxX);
                final fpLabelX = _clampDouble(
                  _xToPixel(
                        falsePositiveX,
                        minX,
                        maxX,
                        leftAxisWidth,
                        plotWidth,
                      ) -
                      regionLabelWidth / 2,
                  leftAxisWidth + 4,
                  constraints.maxWidth - regionLabelWidth,
                );
                final fnLabelX = _clampDouble(
                  _xToPixel(
                        falseNegativeX,
                        minX,
                        maxX,
                        leftAxisWidth,
                        plotWidth,
                      ) -
                      regionLabelWidth / 2,
                  leftAxisWidth + 4,
                  constraints.maxWidth - regionLabelWidth,
                );
                final fpLabelY = _clampDouble(
                  _yToPixel(
                        max(
                          maxY * 0.08,
                          _pdf(falsePositiveX, h0Mean, stdDev) * 0.58,
                        ),
                        minY,
                        maxY,
                        plotHeight,
                      ) -
                      10,
                  20,
                  plotHeight - 24,
                );
                final fnLabelY = _clampDouble(
                  _yToPixel(
                        max(
                          maxY * 0.08,
                          _pdf(falseNegativeX, h1Mean, stdDev) * 0.58,
                        ),
                        minY,
                        maxY,
                        plotHeight,
                      ) -
                      10,
                  20,
                  plotHeight - 24,
                );

                return Stack(
                  children: [
                    RepaintBoundary(
                      child: LineChart(
                        LineChartData(
                          minX: minX,
                          maxX: maxX,
                          minY: minY,
                          maxY: maxY,

                          gridData: const FlGridData(show: true),

                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 0.2,
                                reservedSize: leftAxisWidth,
                                getTitlesWidget: _leftTitle,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                reservedSize: bottomAxisHeight,
                                getTitlesWidget: _bottomTitle,
                              ),
                            ),
                          ),

                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              getTooltipColor: (_) => Colors.white,
                              tooltipBorder: BorderSide(
                                color: Colors.deepPurple.shade200,
                              ),
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  final label = spot.barIndex >= 2
                                      ? 'H₁'
                                      : 'H₀';
                                  return LineTooltipItem(
                                    '$label\nx: ${spot.x.toStringAsFixed(2)}\ny: ${spot.y.toStringAsFixed(3)}',
                                    const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),

                          // Threshold Line
                          extraLinesData: ExtraLinesData(
                            verticalLines: [
                              VerticalLine(
                                x: threshold,
                                color: Colors.black,
                                strokeWidth: 2,
                                dashArray: [5, 5],
                              ),
                            ],
                          ),

                          lineBarsData: [
                            // H0 LEFT
                            LineChartBarData(
                              spots: nullLeft,
                              isCurved: true,
                              color: Colors.green,
                              dotData: const FlDotData(show: false),
                            ),

                            // ALPHA REGION
                            LineChartBarData(
                              spots: nullRight,
                              isCurved: true,
                              color: Colors.red.withValues(alpha: .2),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.red.withValues(alpha: 0.2),
                              ),
                              dotData: const FlDotData(show: false),
                            ),

                            // H1 RIGHT
                            LineChartBarData(
                              spots: altRight,
                              isCurved: true,
                              color: Colors.purple,
                              dotData: const FlDotData(show: false),
                            ),

                            // BETA REGION
                            LineChartBarData(
                              spots: altLeft,
                              isCurved: true,
                              color: Colors.orange.withValues(alpha: 0.4),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.orange.withValues(alpha: 0.3),
                              ),
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                        duration: Duration.zero,
                      ),
                    ),
                    Positioned(
                      top: h0LabelY,
                      left: h0LabelX,
                      child: const _CurveLabel(color: Colors.green, text: "H₀"),
                    ),
                    Positioned(
                      top: h1LabelY,
                      left: h1LabelX,
                      child: const _CurveLabel(
                        color: Colors.purple,
                        text: "H₁",
                      ),
                    ),
                    Positioned(
                      top: 34,
                      left: acceptLabelX,
                      child: const Text(
                        "Accept H₀",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 34,
                      left: rejectLabelX,
                      child: const Text(
                        "Reject H₀",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Positioned(
                      top: fpLabelY,
                      left: fpLabelX,
                      child: const _GraphRegionLabel(
                        color: Colors.red,
                        label: "FP",
                        tooltip: "False Positive",
                      ),
                    ),
                    Positioned(
                      top: fnLabelY,
                      left: fnLabelX,
                      child: const _GraphRegionLabel(
                        color: Colors.orange,
                        label: "FN",
                        tooltip: "False Negative",
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        //  LEGEND (RESPONSIVE)
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: const [
            _LegendItem(color: Colors.green, text: "H₀"),
            _LegendItem(color: Colors.purple, text: "H₁"),
            _LegendItem(color: Colors.red, text: "Type I Error (α)"),
            _LegendItem(color: Colors.orange, text: "Type II Error (β)"),
          ],
        ),

        const SizedBox(height: 10),

        // AXIS LABELS
        const Text(
          "X: Test Statistic   |   Y: Probability Density",
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 6),
      ],
    );
  }

  double _pdf(double x, double mean, double stdDev) {
    return (1 / (stdDev * sqrt(2 * pi))) *
        exp(-pow(x - mean, 2) / (2 * pow(stdDev, 2)));
  }

  Widget _leftTitle(double value, TitleMeta meta) {
    if (value < meta.min || value > meta.max) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      meta: meta,
      child: Text(value.toStringAsFixed(1), style: _axisLabelStyle),
    );
  }

  Widget _bottomTitle(double value, TitleMeta meta) {
    if (value < meta.min || value > meta.max) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      meta: meta,
      child: Text(value.toStringAsFixed(0), style: _axisLabelStyle),
    );
  }

  double _xToPixel(
    double x,
    double minX,
    double maxX,
    double leftAxisWidth,
    double plotWidth,
  ) {
    return leftAxisWidth + ((x - minX) / (maxX - minX)) * plotWidth;
  }

  double _yToPixel(double y, double minY, double maxY, double plotHeight) {
    return ((maxY - y) / (maxY - minY)) * plotHeight;
  }

  double _clampDouble(double value, double minValue, double maxValue) {
    return min(max(value, minValue), maxValue);
  }
}

const TextStyle _axisLabelStyle = TextStyle(
  color: Colors.black87,
  fontSize: 11,
);

class _CurveLabel extends StatelessWidget {
  final Color color;
  final String text;

  const _CurveLabel({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _GraphRegionLabel extends StatelessWidget {
  final Color color;
  final String label;
  final String tooltip;

  const _GraphRegionLabel({
    required this.color,
    required this.label,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          border: Border.all(color: color.withValues(alpha: 0.55)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// LEGEND ITEM
class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
