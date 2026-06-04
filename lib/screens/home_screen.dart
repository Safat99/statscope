// import 'package:flutter/material.dart';

// const String _homeBackgroundImagePath =
//     'assets/image/pexels-rethaferguson-3825573.jpg';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       backgroundColor: Colors.blue.shade50,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         centerTitle: true,
//         elevation: 0,
//         title: const Text("Statistical Error Simulator"),
//       ),
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           Image.asset(
//             _homeBackgroundImagePath,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) => const SizedBox(),
//           ),
//           Container(color: Colors.white.withValues(alpha: 0.58)),
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: () => Navigator.pushNamed(context, '/simulator'),
//                   child: const Text("Start Simulation"),
//                 ),
//                 const SizedBox(height: 16),

//                 ElevatedButton(
//                   onPressed: () => Navigator.pushNamed(context, '/learning'),
//                   child: const Text("Learn Concept"),
//                 ),
//                 const SizedBox(height: 16),

//                 ElevatedButton(
//                   onPressed: () => Navigator.pushNamed(context, '/sample-size'),
//                   child: const Text("Sample Size Calculator"),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// ----------------

import 'package:flutter/material.dart';

const String _homeBackgroundImagePath =
    'assets/image/pexels-rethaferguson-3825573.jpg';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Statistical Error Simulator",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _homeBackgroundImagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),

          // Light overlay so text stays readable
          Container(color: Colors.white.withValues(alpha: 0.62)),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.analytics_outlined,
                        size: 64,
                        color: Colors.indigo,
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        "Statistical Error Simulator",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Explore Type I error, Type II error, power, sample size, "
                        "and batch treatment comparisons.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                      ),

                      const SizedBox(height: 28),

                      _homeCard(
                        context,
                        title: "Start Simulation",
                        subtitle:
                            "Visualize alpha, beta, power, and overlapping distributions.",
                        route: "/simulator",
                        icon: Icons.show_chart,
                      ),

                      _homeCard(
                        context,
                        title: "Learning Mode",
                        subtitle:
                            "Understand false positives, false negatives, and trade-offs.",
                        route: "/learning",
                        icon: Icons.school_outlined,
                      ),

                      _homeCard(
                        context,
                        title: "Sample Size Calculator",
                        subtitle:
                            "Calculate required sample size for one selected study design.",
                        route: "/sample-size",
                        icon: Icons.calculate_outlined,
                      ),

                      _homeCard(
                        context,
                        title: "Bulk Treatment Analysis",
                        subtitle:
                            "Paste CSV data and calculate sample size for treatment comparisons.",
                        route: "/bulk-analysis",
                        icon: Icons.table_chart_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String route,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white.withValues(alpha: 0.92),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade50,
          child: Icon(icon, color: Colors.indigo),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
