import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String professorImagePath = 'assets/image/professor.jpg';
  static const String developerImagePath = 'assets/image/developer.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About & Acknowledgements")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionCard(
                  title: "About This App",
                  child: const Text(
                    "This application is an interactive teaching and planning tool "
                    "for understanding Type I error, Type II error, statistical power, "
                    "sample size estimation, and batch treatment comparisons.\n\n"
                    "The app was developed to support learning and discussion around "
                    "hypothesis testing, false positives, false negatives, and power analysis "
                    "using visual and calculator-based examples.",
                    style: TextStyle(fontSize: 15),
                  ),
                ),

                const SizedBox(height: 16),

                _sectionCard(
                  title: "Project Supervisor",
                  child: _profileBlock(
                    imagePath: professorImagePath,
                    name: "Dr. Tony Hartshorn",
                    role:
                        "Associate Professor | Soil landscape processes | Project Supervisor / Faculty Mentor",
                    description:
                        "Phone: (480) 406-1277\n"
                        "Email: anthony.hartshorn@montana.edu\n"
                        "Office: Leon Johnson Hall 811\n\n"
                        "Research Interests: soils, soil literacy, soil remediation, "
                        "carbon literacy, carbon numeracy, improved grazing management, "
                        "improved cropland management, soil organic matter dynamics, "
                        "soil respiration dynamics.\n\n"
                        "Teaching Interests: soils, soil literacy, soil remediation, "
                        "carbon literacy, carbon numeracy, improved grazing management, "
                        "improved cropland management, soil organic matter dynamics, "
                        "soil respiration dynamics.",
                  ),
                ),

                const SizedBox(height: 16),

                _sectionCard(
                  title: "Developer",
                  child: _profileBlock(
                    imagePath: developerImagePath,
                    name: "Safat",
                    role: "App Developer / Graduate Research Assistant",
                    description:
                        "Developed the interactive Flutter application, including the "
                        "alpha-beta visualizer, learning mode, sample size calculator, "
                        "and bulk treatment analysis module.",
                  ),
                ),

                const SizedBox(height: 16),

                _sectionCard(
                  title: "Acknowledgements",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "This prototype was developed with guidance, study references, "
                        "and inspiration from multiple educational and computational tools.",
                      ),
                      SizedBox(height: 12),

                      Text(
                        "Credits and references:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),

                      SelectableText(
                        "• ChatGPT was used as a coding and writing assistant during "
                        "development, debugging, and documentation drafting.",
                      ),
                      SizedBox(height: 6),

                      SelectableText(
                        "• Desmos graph reference:\n"
                        "https://www.desmos.com/calculator/qf0rrwuivl",
                      ),
                      SizedBox(height: 6),

                      SelectableText(
                        "• ClinCalc sample size calculator reference:\n"
                        "https://clincalc.com/Stats/SampleSize.aspx",
                      ),
                      SizedBox(height: 6),

                      SelectableText(
                        "• Statistical concepts were also studied using educational "
                        "materials such as StatQuest-style explanations of hypothesis testing, "
                        "Type I error, Type II error, and power analysis.",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Note: This app is intended as an educational and planning prototype. "
                  "Study-specific statistical decisions should be reviewed with a qualified "
                  "statistician or domain expert before final experimental design.",
                  style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                ),
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

  Widget _profileBlock({
    required String imagePath,
    required String name,
    required String role,
    required String description,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        final image = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            imagePath,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, size: 56, color: Colors.indigo),
              );
            },
          ),
        );

        final text = Expanded(
          child: Column(
            crossAxisAlignment: isWide
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: isWide ? TextAlign.start : TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                role,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.indigo,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: isWide ? TextAlign.start : TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 14),
                textAlign: isWide ? TextAlign.start : TextAlign.center,
              ),
            ],
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [image, const SizedBox(width: 16), text],
          );
        }

        return Column(children: [image, const SizedBox(height: 12), text]);
      },
    );
  }
}
