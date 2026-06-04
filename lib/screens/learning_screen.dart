import 'package:flutter/material.dart';
import '../widgets/graph_widget.dart';
import '../utils/math_utils.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen>
    with SingleTickerProviderStateMixin {
  double alpha = 0.05;

  // This is the standardized distance between H0 and H1 in the learning graph.
  // d = |mu1 - mu0| / sigma
  double effectSize = 0.50;

  // This is the target power used for the quick sample-size estimate.
  double desiredPower = 0.80;

  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    animation =
        Tween<double>(begin: 0.20, end: 0.01).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeInOut),
        )..addListener(() {
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
    final threshold = inverseNormal(1 - alpha);
    final betaFromGraph = normalCDF(threshold - effectSize);
    final powerFromGraph = 1 - betaFromGraph;

    final targetBeta = 1 - desiredPower;

    final zAlpha = inverseNormal(1 - alpha / 2);
    final zPower = inverseNormal(desiredPower);

    final requiredNPerGroup = twoSampleContinuousNPerGroupFromEffectSize(
      effectSize: effectSize,
      alpha: alpha,
      power: desiredPower,
    ).ceil();

    final totalRequiredN = 2 * requiredNPerGroup;

    return Scaffold(
      appBar: AppBar(title: const Text("Learning Mode")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionCard(
                  title: "1. What are we learning?",
                  child: const Text(
                    "This page is a conceptual simulator for Type I error, Type II error, "
                    "false positives, false negatives, and power.\n\n"
                    "Example story:\n"
                    "H₀: A new fertilizer does not improve yield.\n"
                    "H₁: A new fertilizer improves yield.",
                    style: TextStyle(fontSize: 15),
                  ),
                ),

                const SizedBox(height: 16),

                _sectionCard(
                  title: "2. Interactive Error Graph",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GraphWidget(
                        alpha: alpha,
                        effectSize: effectSize,
                        nullMean: 0,
                        altMean: effectSize,
                        standardDeviation: 1,
                      ),

                      const SizedBox(height: 16),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          _statCard("α", alpha, "False positive risk"),
                          _statCard("β", betaFromGraph, "False negative risk"),
                          _statCard("Power", powerFromGraph, "1 - β"),
                          _statCard("d", effectSize, "Effect size"),
                        ],
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        "Adjust α: lower α makes the test stricter.",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: alpha,
                        min: 0.01,
                        max: 0.20,
                        divisions: 190,
                        label: alpha.toStringAsFixed(3),
                        onChanged: (val) {
                          setState(() => alpha = val);
                        },
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Adjust effect size: larger effect size separates H₀ and H₁ more.",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: effectSize,
                        min: 0.20,
                        max: 2.50,
                        divisions: 230,
                        label: effectSize.toStringAsFixed(2),
                        onChanged: (val) {
                          setState(() => effectSize = val);
                        },
                      ),

                      const SizedBox(height: 12),

                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            controller.forward(from: 0);
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text("Show α/β Trade-off Animation"),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _sectionCard(
                  title: "3. What assumptions are used in this graph?",
                  child: const Text(
                    "This learning graph uses a simplified normal-distribution model:\n\n"
                    "H₀ distribution: mean = 0, standard deviation = 1\n"
                    "H₁ distribution: mean = effect size d, standard deviation = 1\n\n"
                    "The x-axis is a standardized test statistic, not raw yield or protein data. "
                    "The graph is for teaching the idea of overlap, α, β, and power.",
                    style: TextStyle(fontSize: 14),
                  ),
                ),

                const SizedBox(height: 16),

                _sectionCard(
                  title: "4. Quick Sample Size Demonstration",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "This quick calculation uses the current α and effect size from the graph, "
                        "plus a desired target power selected below.",
                      ),

                      const SizedBox(height: 14),

                      Text(
                        "Desired target power: ${desiredPower.toStringAsFixed(2)} "
                        "   |   Target β: ${targetBeta.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: desiredPower,
                        min: 0.50,
                        max: 0.95,
                        divisions: 45,
                        label: desiredPower.toStringAsFixed(2),
                        onChanged: (val) {
                          setState(() => desiredPower = val);
                        },
                      ),

                      const SizedBox(height: 12),

                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Estimated sample size",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Required n/group: $requiredNPerGroup",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("Total required n: $totalRequiredN"),
                              const SizedBox(height: 10),
                              Text(
                                "Used values: α = ${alpha.toStringAsFixed(3)}, "
                                "desired power = ${desiredPower.toStringAsFixed(2)}, "
                                "effect size d = ${effectSize.toStringAsFixed(2)}",
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Formula used here:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      // const Text("n/group = 2 × ((Z₁₋α/₂ + Zpower) / d)²"),
                      const SizedBox(height: 6),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "n/group = 2 × ((Z₁₋α/₂ + Zpower) / d)²",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text("Z₁₋α/₂ = ${zAlpha.toStringAsFixed(3)}"),
                            Text("Zpower = ${zPower.toStringAsFixed(3)}"),
                            Text("d = ${effectSize.toStringAsFixed(2)}"),
                            const SizedBox(height: 8),
                            Text(
                              "n/group = 2 × ((${zAlpha.toStringAsFixed(3)} + "
                              "${zPower.toStringAsFixed(3)}) / "
                              "${effectSize.toStringAsFixed(2)})²",
                            ),
                            Text("n/group ≈ $requiredNPerGroup"),
                            Text("total n ≈ $totalRequiredN"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Meaning:\n"
                        "n/group is the estimated number of samples needed in each group. "
                        "This simplified formula assumes two independent groups, a continuous outcome, "
                        "equal group sizes, and a standardized effect size d.",
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _sectionCard(
                  title: "5. Main takeaway",
                  child: const Text(
                    "Lowering α reduces false positives, but usually increases β unless sample size "
                    "or effect size increases.\n\n"
                    "Increasing power lowers β, but usually requires more samples.\n\n"
                    "So, we cannot simply demand both lower α and lower β for free. "
                    "The cost is usually larger sample size.",
                    style: TextStyle(fontSize: 14),
                  ),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/sample-size'),
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text("Open Detailed Sample Size Calculator"),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/bulk-analysis'),
                      icon: const Icon(Icons.table_chart_outlined),
                      label: const Text("Open Bulk Treatment Analysis"),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, double value, String subtitle) {
    return SizedBox(
      width: 150,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 5),
              Text(
                value.toStringAsFixed(3),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
