import 'package:flutter/material.dart';
import '../widgets/graph_widget.dart';
import 'power_analysis_widget.dart';
import '../utils/math_utils.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen>
    with SingleTickerProviderStateMixin {
  double alpha = 0.05;
  double effectSize = 2;

  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    animation = Tween<double>(begin: 0.2, end: 0.01).animate(controller)
      ..addListener(() {
        setState(() {
          alpha = animation.value;
        });
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double threshold = inverseNormal(1 - alpha);
    double beta = normalCDF(threshold - effectSize);
    double power = 1 - beta;

    return Scaffold(
      appBar: AppBar(title: const Text("Learning Mode")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  TITLE
            const Text(
              "Understanding Type I & Type II Errors",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // STORY SECTION
            const Text(
              "Imagine you are testing a new fertilizer.\n\n"
              "H₀: No improvement\n"
              "H₁: Improvement exists",
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 20),

            // GRAPH (NO FIXED HEIGHT HERE ❗)
            GraphWidget(alpha: alpha, effectSize: effectSize),

            const SizedBox(height: 20),

            // METRICS (CLEAN UI)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statCard("Alpha", alpha),
                _statCard("Beta", beta),
                _statCard("Power", power),
              ],
            ),

            const SizedBox(height: 20),

            // 🎚 SLIDER SECTION
            const Text(
              "Adjust Significance Level (α)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Slider(
              value: alpha,
              min: 0.01,
              max: 0.2,
              onChanged: (val) {
                setState(() => alpha = val);
              },
            ),

            const SizedBox(height: 10),

            // 🎬 ANIMATION BUTTON
            Center(
              child: ElevatedButton(
                onPressed: () {
                  controller.forward(from: 0);
                },
                child: const Text("▶ Show Trade-off Animation"),
              ),
            ),

            const SizedBox(height: 20),

            // EXPLANATION
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "If we reduce alpha (make the test stricter),\n"
                "we reduce false positives.\n\n"
                "BUT → we increase beta (miss real effects).\n\n"
                "This trade-off is fundamental in hypothesis testing.",
                style: TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 10),

            // POWER ANALYSIS SECTION
            const Text(
              "Power Analysis (Sample Size Estimation)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            PowerAnalysisWidget(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // STAT CARD WIDGET
  Widget _statCard(String label, double value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 5),
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
