import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/math_utils.dart';

class GraphWidget extends StatelessWidget {
  final double alpha;
  final double effectSize;

  const GraphWidget({super.key, required this.alpha, required this.effectSize});

  @override
  Widget build(BuildContext context) {
    double threshold = inverseNormal(1 - alpha);

    List<FlSpot> nullLeft = [];
    List<FlSpot> nullRight = [];
    List<FlSpot> altLeft = [];
    List<FlSpot> altRight = [];

    for (double x = -4; x <= 6; x += 0.05) {
      double yNull = _pdf(x, 0);
      double yAlt = _pdf(x, effectSize);

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
        SizedBox(
          height: 220, // THIS FIXES OVERFLOW
          child: LineChart(
            LineChartData(
              minX: -4,
              maxX: 6,
              minY: 0,
              maxY: 0.5,

              gridData: FlGridData(show: true),

              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
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
                  dotData: FlDotData(show: false),
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
                  dotData: FlDotData(show: false),
                ),

                // H1 RIGHT
                LineChartBarData(
                  spots: altRight,
                  isCurved: true,
                  color: Colors.purple,
                  dotData: FlDotData(show: false),
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
                  dotData: FlDotData(show: false),
                ),
              ],
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

  double _pdf(double x, double mean) {
    return (1 / sqrt(2 * pi)) * exp(-pow(x - mean, 2) / 2);
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
