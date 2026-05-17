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
  double effectSize = 2;

  @override
  Widget build(BuildContext context) {
    double threshold = inverseNormal(1 - alpha);
    double beta = normalCDF(threshold - effectSize);
    double power = 1 - beta;

    return Scaffold(
      appBar: AppBar(title: const Text("Simulation")),
      body: Column(
        children: [
          GraphWidget(alpha: alpha, effectSize: effectSize),
          Text("Alpha: ${alpha.toStringAsFixed(2)}"),
          Slider(
            value: alpha,
            min: 0.01,
            max: 0.2,
            onChanged: (val) {
              setState(() => alpha = val);
            },
          ),

          Text("Effect Size: ${effectSize.toStringAsFixed(2)}"),
          Slider(
            value: effectSize,
            min: 0,
            max: 3,
            onChanged: (val) {
              setState(() => effectSize = val);
            },
          ),

          Wrap(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
