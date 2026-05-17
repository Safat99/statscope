import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistical Error Simulator")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/simulator'),
              child: const Text("Start Simulation"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/learning'),
              child: const Text("Learn Concept"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/sample-size'),
              child: const Text("Sample Size Calculator"),
            ),
          ],
        ),
      ),
    );
  }
}
