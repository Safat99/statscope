import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/simulator_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/sample_size_screen.dart';
import 'screens/bulk_analysis_screen.dart';
import 'screens/about_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stat Simulator',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const HomeScreen(),
        '/simulator': (context) => const SimulatorScreen(),
        '/learning': (context) => const LearningScreen(),
        '/sample-size': (context) => const SampleSizeScreen(),
        '/bulk-analysis': (context) => const BulkAnalysisScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}
