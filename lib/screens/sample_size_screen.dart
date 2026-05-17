import 'package:flutter/material.dart';
import '../utils/math_utils.dart';
import 'dart:math';

class SampleSizeScreen extends StatefulWidget {
  const SampleSizeScreen({super.key});

  @override
  State<SampleSizeScreen> createState() => _SampleSizeScreenState();
}

class _SampleSizeScreenState extends State<SampleSizeScreen> {
  String studyType = "One Sample Continuous";

  // Common parameters
  double alpha = 0.05;
  double power = 0.8;

  // Continuous (one sample)
  double mu0 = 50;
  double mu1 = 60;
  double sigma = 10;

  // Two-group continuous
  double mean1 = 50;
  double mean2 = 60;

  // Dichotomous
  double p1 = 0.05;
  double p2 = 0.10;

  double sampleSize = 0;

  void calculateSampleSize() {
    double zAlpha = inverseNormal(1 - alpha / 2);
    double zBeta = inverseNormal(power);

    double n = 0;

    if (studyType == "One Sample Continuous") {
      n = pow(sigma * (zAlpha + zBeta) / (mu1 - mu0), 2).toDouble();
    } else if (studyType == "Two Sample Continuous") {
      n = 2 * pow(sigma * (zAlpha + zBeta) / (mean2 - mean1), 2).toDouble();
    } else if (studyType == "Dichotomous") {
      double pbar = (p1 + p2) / 2;
      double qbar = 1 - pbar;

      double numerator =
          zAlpha * sqrt(2 * pbar * qbar) +
          zBeta * sqrt(p1 * (1 - p1) + p2 * (1 - p2));

      double delta = (p2 - p1);

      n = pow(numerator / delta, 2).toDouble();
    }

    setState(() {
      sampleSize = n;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sample Size Calculator")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE
            const Text(
              "Determine Minimum Sample Size for Adequate Power",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            //  STUDY TYPE
            const Text("Study Type"),
            DropdownButton<String>(
              value: studyType,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: "One Sample Continuous",
                  child: Text("Continuous (One Sample)"),
                ),
                DropdownMenuItem(
                  value: "Two Sample Continuous",
                  child: Text("Continuous (Two Groups)"),
                ),
                DropdownMenuItem(
                  value: "Dichotomous",
                  child: Text("Dichotomous (Two Groups)"),
                ),
              ],
              onChanged: (val) {
                setState(() => studyType = val!);
              },
            ),

            const SizedBox(height: 20),

            // PARAMETERS
            const Text(
              "Study Parameters",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            if (studyType == "One Sample Continuous") ...[
              _input("Population Mean (μ₀)", mu0, (v) => mu0 = v),
              _input("Expected Mean (μ₁)", mu1, (v) => mu1 = v),
              _input("Standard Deviation (σ)", sigma, (v) => sigma = v),
            ],

            if (studyType == "Two Sample Continuous") ...[
              _input("Group 1 Mean", mean1, (v) => mean1 = v),
              _input("Group 2 Mean", mean2, (v) => mean2 = v),
              _input("Standard Deviation (σ)", sigma, (v) => sigma = v),
            ],

            if (studyType == "Dichotomous") ...[
              _input("Proportion Group 1 (p₁)", p1, (v) => p1 = v),
              _input("Proportion Group 2 (p₂)", p2, (v) => p2 = v),
            ],

            const SizedBox(height: 20),

            // ERROR SETTINGS
            const Text(
              "Error Rates",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            Text("Alpha (Type I Error): ${alpha.toStringAsFixed(2)}"),
            Slider(
              value: alpha,
              min: 0.01,
              max: 0.2,
              onChanged: (v) => setState(() => alpha = v),
            ),

            Text("Power (1 - Beta): ${power.toStringAsFixed(2)}"),
            Slider(
              value: power,
              min: 0.5,
              max: 0.95,
              onChanged: (v) => setState(() => power = v),
            ),

            const SizedBox(height: 20),

            // BUTTON
            Center(
              child: ElevatedButton(
                onPressed: calculateSampleSize,
                child: const Text("Calculate"),
              ),
            ),

            const SizedBox(height: 20),

            // RESULTS
            if (sampleSize > 0)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "Results",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Required Sample Size ≈ ${sampleSize.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, double value, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        onChanged: (val) {
          onChanged(double.tryParse(val) ?? value);
        },
      ),
    );
  }
}
