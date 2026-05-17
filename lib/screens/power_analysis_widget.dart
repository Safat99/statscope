import 'package:flutter/material.dart';
import '../utils/math_utils.dart';
import 'dart:math';

class PowerAnalysisWidget extends StatefulWidget {
  const PowerAnalysisWidget({super.key});

  @override
  State<PowerAnalysisWidget> createState() => _PowerAnalysisWidgetState();
}

class _PowerAnalysisWidgetState extends State<PowerAnalysisWidget> {
  double alpha = 0.05;
  double power = 0.8;
  double effectSize = 0.5;

  @override
  Widget build(BuildContext context) {
    double zAlpha = inverseNormal(1 - alpha);
    double zBeta = inverseNormal(power);


    double sampleSize = pow((zAlpha + zBeta) / effectSize, 2).toDouble();

    return Column(
      children: [
        Text("Alpha: ${alpha.toStringAsFixed(2)}"),
        Slider(
          value: alpha,
          min: 0.01,
          max: 0.2,
          onChanged: (val) {
            setState(() => alpha = val);
          },
        ),

        Text("Power: ${power.toStringAsFixed(2)}"),
        Slider(
          value: power,
          min: 0.5,
          max: 0.95,
          onChanged: (val) {
            setState(() => power = val);
          },
        ),

        Text("Effect Size: ${effectSize.toStringAsFixed(2)}"),
        Slider(
          value: effectSize,
          min: 0.2,
          max: 1.5,
          onChanged: (val) {
            setState(() => effectSize = val);
          },
        ),

        const SizedBox(height: 10),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "Required Sample Size ≈ ${sampleSize.toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
