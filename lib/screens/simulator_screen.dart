import 'package:flutter/material.dart';
import '../widgets/graph_widget.dart';
import '../utils/math_utils.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  double alpha = 0.05;
  double nullMean = 0;
  double altMean = 2;
  double standardDeviation = 1;

  @override
  Widget build(BuildContext context) {
    double threshold = nullMean + standardDeviation * inverseNormal(1 - alpha);
    double beta = normalCDF((threshold - altMean) / standardDeviation);
    double power = 1 - beta;

    return Scaffold(
      appBar: AppBar(title: const Text("Simulation")),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    children: [
                      GraphWidget(
                        alpha: alpha,
                        effectSize: altMean,
                        nullMean: nullMean,
                        altMean: altMean,
                        standardDeviation: standardDeviation,
                      ),
                      _labeledSlider(
                        label: "Alpha",
                        value: alpha,
                        min: 0.01,
                        max: 0.5,
                        divisions: 49,
                        onChanged: (val) {
                          setState(() => alpha = val);
                        },
                      ),
                      _labeledSlider(
                        label: "H₀ Mean",
                        value: nullMean,
                        min: -2,
                        max: 2,
                        divisions: 40,
                        onChanged: (val) {
                          setState(() => nullMean = val);
                        },
                      ),
                      _labeledSlider(
                        label: "H₁ Mean",
                        value: altMean,
                        min: -2,
                        max: 4,
                        divisions: 60,
                        onChanged: (val) {
                          setState(() => altMean = val);
                        },
                      ),
                      _labeledSlider(
                        label: "Standard Deviation",
                        value: standardDeviation,
                        min: 0.5,
                        max: 2,
                        divisions: 30,
                        onChanged: (val) {
                          setState(() => standardDeviation = val);
                        },
                      ),
                      Wrap(
                        children: [_card("Beta", beta), _card("Power", power)],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/learning');
                        },
                        child: const Text("Learn Why Trade-off Happens"),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _labeledSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Text("$label: ${value.toStringAsFixed(2)}"),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _card(String title, double value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(children: [Text(title), Text(value.toStringAsFixed(2))]),
      ),
    );
  }
}
