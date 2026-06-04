import 'package:flutter/material.dart';
import '../utils/math_utils.dart';

class SampleSizeScreen extends StatefulWidget {
  const SampleSizeScreen({super.key});

  @override
  State<SampleSizeScreen> createState() => _SampleSizeScreenState();
}

class _SampleSizeScreenState extends State<SampleSizeScreen> {
  String studyType = "One Sample Continuous";

  double alpha = 0.05;
  double power = 0.80;

  double? sampleSizePerGroup;
  double? totalSampleSize;
  String? resultNote;
  String? errorMessage;

  late final TextEditingController mu0Controller;
  late final TextEditingController mu1Controller;
  late final TextEditingController sigmaController;
  late final TextEditingController mean1Controller;
  late final TextEditingController mean2Controller;
  late final TextEditingController p1Controller;
  late final TextEditingController p2Controller;

  @override
  void initState() {
    super.initState();

    // These are visible example defaults, not hidden values.
    mu0Controller = TextEditingController(text: "50");
    mu1Controller = TextEditingController(text: "60");
    sigmaController = TextEditingController(text: "10");

    mean1Controller = TextEditingController(text: "50");
    mean2Controller = TextEditingController(text: "60");

    p1Controller = TextEditingController(text: "0.05");
    p2Controller = TextEditingController(text: "0.10");
  }

  @override
  void dispose() {
    mu0Controller.dispose();
    mu1Controller.dispose();
    sigmaController.dispose();
    mean1Controller.dispose();
    mean2Controller.dispose();
    p1Controller.dispose();
    p2Controller.dispose();
    super.dispose();
  }

  void clearResult() {
    setState(() {
      sampleSizePerGroup = null;
      totalSampleSize = null;
      resultNote = null;
      errorMessage = null;
    });
  }

  double readNumber(TextEditingController controller, String label) {
    final value = double.tryParse(controller.text.trim());

    if (value == null) {
      throw ArgumentError('$label must be a valid number.');
    }

    return value;
  }

  void calculateSampleSize() {
    try {
      double n;
      double total;
      String note;

      if (studyType == "One Sample Continuous") {
        final mu0 = readNumber(mu0Controller, "Population mean");
        final mu1 = readNumber(mu1Controller, "Expected mean");
        final sigma = readNumber(sigmaController, "Standard deviation");

        n = oneSampleContinuousN(
          mu0: mu0,
          mu1: mu1,
          sigma: sigma,
          alpha: alpha,
          power: power,
        );

        total = n;
        note =
            "For one-sample continuous design, this is the total required sample size.";
      } else if (studyType == "Two Sample Continuous") {
        final mean1 = readNumber(mean1Controller, "Group 1 mean");
        final mean2 = readNumber(mean2Controller, "Group 2 mean");
        final sigma = readNumber(sigmaController, "Standard deviation");

        n = twoSampleContinuousNPerGroup(
          mean1: mean1,
          mean2: mean2,
          sigma: sigma,
          alpha: alpha,
          power: power,
        );

        total = 2 * n;
        note =
            "For two-group continuous design, this is required sample size per group.";
      } else {
        final p1 = readNumber(p1Controller, "Proportion group 1");
        final p2 = readNumber(p2Controller, "Proportion group 2");

        n = dichotomousTwoGroupNPerGroup(
          p1: p1,
          p2: p2,
          alpha: alpha,
          power: power,
        );

        total = 2 * n;
        note =
            "For two-group dichotomous design, this is required sample size per group.";
      }

      setState(() {
        sampleSizePerGroup = n.ceilToDouble();
        totalSampleSize = total.ceilToDouble();
        resultNote = note;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        sampleSizePerGroup = null;
        totalSampleSize = null;
        resultNote = null;
        errorMessage = e.toString().replaceAll("Invalid argument(s): ", "");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final beta = 1 - power;

    return Scaffold(
      appBar: AppBar(title: const Text("Sample Size Calculator")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionCard(
                  title: "Study Design",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Choose the study design/formula. The inputs below will change based on this selection.",
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: studyType,
                        decoration: const InputDecoration(
                          labelText: "Formula / study type",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "One Sample Continuous",
                            child: Text("Continuous endpoint — One sample"),
                          ),
                          DropdownMenuItem(
                            value: "Two Sample Continuous",
                            child: Text(
                              "Continuous endpoint — Two independent groups",
                            ),
                          ),
                          DropdownMenuItem(
                            value: "Dichotomous",
                            child: Text(
                              "Dichotomous endpoint — Two independent groups",
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            studyType = val!;
                            sampleSizePerGroup = null;
                            totalSampleSize = null;
                            resultNote = null;
                            errorMessage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _sectionCard(
                  title: "Study Parameters",
                  child: Column(
                    children: [
                      if (studyType == "One Sample Continuous") ...[
                        _numberInput("Population Mean (μ₀)", mu0Controller),
                        _numberInput("Expected Study Mean (μ₁)", mu1Controller),
                        _numberInput("Standard Deviation (σ)", sigmaController),
                      ],
                      if (studyType == "Two Sample Continuous") ...[
                        _numberInput("Group 1 Mean", mean1Controller),
                        _numberInput("Group 2 Mean", mean2Controller),
                        _numberInput(
                          "Common Standard Deviation (σ)",
                          sigmaController,
                        ),
                      ],
                      if (studyType == "Dichotomous") ...[
                        _numberInput(
                          "Proportion Group 1 (p₁), e.g. 0.05",
                          p1Controller,
                        ),
                        _numberInput(
                          "Proportion Group 2 (p₂), e.g. 0.10",
                          p2Controller,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _sectionCard(
                  title: "Error Rates",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Alpha (Type I error / false positive risk): ${alpha.toStringAsFixed(3)}",
                      ),
                      Slider(
                        value: alpha,
                        min: 0.01,
                        max: 0.20,
                        divisions: 190,
                        label: alpha.toStringAsFixed(3),
                        onChanged: (v) {
                          setState(() {
                            alpha = v;
                            sampleSizePerGroup = null;
                            totalSampleSize = null;
                            resultNote = null;
                            errorMessage = null;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Power: ${power.toStringAsFixed(3)}     Beta: ${beta.toStringAsFixed(3)}",
                      ),
                      Slider(
                        value: power,
                        min: 0.50,
                        max: 0.95,
                        divisions: 45,
                        label: power.toStringAsFixed(2),
                        onChanged: (v) {
                          setState(() {
                            power = v;
                            sampleSizePerGroup = null;
                            totalSampleSize = null;
                            resultNote = null;
                            errorMessage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: ElevatedButton.icon(
                    onPressed: calculateSampleSize,
                    icon: const Icon(Icons.calculate),
                    label: const Text("Calculate Sample Size"),
                  ),
                ),

                const SizedBox(height: 16),

                if (errorMessage != null)
                  Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),

                if (sampleSizePerGroup != null && totalSampleSize != null)
                  _sectionCard(
                    title: "Results",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (studyType == "One Sample Continuous") ...[
                          Text(
                            "Required total sample size: ${totalSampleSize!.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else ...[
                          Text(
                            "Required sample size per group: ${sampleSizePerGroup!.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Total required sample size: ${totalSampleSize!.toStringAsFixed(0)}",
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(resultNote ?? ""),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _numberInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => clearResult(),
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
}
