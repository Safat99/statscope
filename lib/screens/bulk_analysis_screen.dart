import 'package:flutter/material.dart';
import '../utils/math_utils.dart';

class BulkAnalysisScreen extends StatefulWidget {
  const BulkAnalysisScreen({super.key});

  @override
  State<BulkAnalysisScreen> createState() => _BulkAnalysisScreenState();
}

class BatchResult {
  final String comparison;
  final double mean1;
  final double mean2;
  final double sd1;
  final double sd2;
  final double diff;
  final double pooledSd;
  final double effectSize;
  final int nPerGroup;
  final int totalN;

  BatchResult({
    required this.comparison,
    required this.mean1,
    required this.mean2,
    required this.sd1,
    required this.sd2,
    required this.diff,
    required this.pooledSd,
    required this.effectSize,
    required this.nPerGroup,
    required this.totalN,
  });
}

class _BulkAnalysisScreenState extends State<BulkAnalysisScreen> {
  final TextEditingController csvController = TextEditingController();

  List<String> headers = [];
  List<Map<String, String>> rows = [];

  List<String> numericColumns = [];
  List<String> groupingColumns = [];
  List<String> groupValues = [];

  String? dependentColumn;
  String? groupingColumn;
  String? groupA;
  String? groupB;

  double alpha = 0.05;
  double power = 0.80;

  String? errorMessage;
  List<BatchResult> results = [];

  @override
  void dispose() {
    csvController.dispose();
    super.dispose();
  }

  void loadExampleCsv() {
    csvController.text = '''Field,year,rep,treatment,Nrate,yield,protein,ANUE
F1,2022,1,Fallow,112,3100,11.8,34
F1,2022,2,Fallow,112,3200,12.0,35
F1,2022,3,Fallow,112,3050,11.6,33
F1,2022,4,Fallow,112,3150,11.9,34
F1,2022,1,Pea,112,3500,12.8,39
F1,2022,2,Pea,112,3600,13.1,41
F1,2022,3,Pea,112,3450,12.7,38
F1,2022,4,Pea,112,3550,12.9,40
F1,2022,1,Grass_mix,112,3300,12.2,36
F1,2022,2,Grass_mix,112,3400,12.5,37
F1,2022,3,Grass_mix,112,3350,12.3,36
F1,2022,4,Grass_mix,112,3420,12.4,37''';
    parseCsv();
  }

  List<String> splitCsvLine(String line) {
    // Simple CSV parser for clean CSV files without quoted commas.
    return line.split(',').map((e) => e.trim()).toList();
  }

  void parseCsv() {
    try {
      final raw = csvController.text.trim();

      if (raw.isEmpty) {
        throw ArgumentError('Please paste CSV text first.');
      }

      final lines = raw
          .split(RegExp(r'\r?\n'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      if (lines.length < 3) {
        throw ArgumentError(
          'CSV must include a header row and at least two data rows.',
        );
      }

      final parsedHeaders = splitCsvLine(lines.first);

      if (parsedHeaders.length < 2) {
        throw ArgumentError('CSV must contain at least two columns.');
      }

      final parsedRows = <Map<String, String>>[];

      for (int i = 1; i < lines.length; i++) {
        final values = splitCsvLine(lines[i]);

        if (values.length != parsedHeaders.length) {
          throw ArgumentError(
            'Row ${i + 1} has ${values.length} values but header has ${parsedHeaders.length} columns.',
          );
        }

        final row = <String, String>{};

        for (int j = 0; j < parsedHeaders.length; j++) {
          row[parsedHeaders[j]] = values[j];
        }

        parsedRows.add(row);
      }

      final detectedNumeric = <String>[];
      final detectedGrouping = <String>[];

      for (final h in parsedHeaders) {
        final nonEmptyValues = parsedRows
            .map((r) => r[h] ?? '')
            .where((v) => v.trim().isNotEmpty)
            .toList();

        final numericCount = nonEmptyValues
            .where((v) => double.tryParse(v) != null)
            .length;

        if (nonEmptyValues.isNotEmpty &&
            numericCount / nonEmptyValues.length >= 0.80) {
          detectedNumeric.add(h);
        } else {
          detectedGrouping.add(h);
        }
      }

      setState(() {
        headers = parsedHeaders;
        rows = parsedRows;

        numericColumns = detectedNumeric;
        groupingColumns = detectedGrouping;

        dependentColumn = detectedNumeric.isNotEmpty
            ? detectedNumeric.first
            : null;
        groupingColumn = detectedGrouping.contains('treatment')
            ? 'treatment'
            : detectedGrouping.isNotEmpty
            ? detectedGrouping.first
            : null;

        results = [];
        errorMessage = null;

        refreshGroupValues();
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll("Invalid argument(s): ", "");
        headers = [];
        rows = [];
        numericColumns = [];
        groupingColumns = [];
        groupValues = [];
        dependentColumn = null;
        groupingColumn = null;
        groupA = null;
        groupB = null;
        results = [];
      });
    }
  }

  void refreshGroupValues() {
    if (groupingColumn == null || rows.isEmpty) {
      groupValues = [];
      groupA = null;
      groupB = null;
      return;
    }

    final values =
        rows
            .map((r) => r[groupingColumn] ?? '')
            .where((v) => v.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    groupValues = values;
    groupA = values.isNotEmpty ? values.first : null;
    groupB = values.length > 1 ? values[1] : null;
  }

  List<double> valuesForGroup(String groupName) {
    if (dependentColumn == null || groupingColumn == null) {
      return [];
    }

    return rows
        .where((r) => r[groupingColumn] == groupName)
        .map((r) => double.tryParse(r[dependentColumn!] ?? ''))
        .whereType<double>()
        .toList();
  }

  BatchResult calculatePair(String a, String b) {
    final valuesA = valuesForGroup(a);
    final valuesB = valuesForGroup(b);

    if (valuesA.length < 2 || valuesB.length < 2) {
      throw ArgumentError(
        '$a vs $b needs at least 2 numeric observations in each group.',
      );
    }

    final m1 = mean(valuesA);
    final m2 = mean(valuesB);
    final s1 = sampleStdDev(valuesA);
    final s2 = sampleStdDev(valuesB);
    final sp = pooledStdDev(s1, s2);
    final diff = (m2 - m1).abs();
    final d = effectSizeFromMeans(mean1: m1, mean2: m2, pooledSd: sp);

    final n = twoSampleContinuousNPerGroupFromEffectSize(
      effectSize: d,
      alpha: alpha,
      power: power,
    ).ceil();

    return BatchResult(
      comparison: '$a vs $b',
      mean1: m1,
      mean2: m2,
      sd1: s1,
      sd2: s2,
      diff: diff,
      pooledSd: sp,
      effectSize: d,
      nPerGroup: n,
      totalN: 2 * n,
    );
  }

  void calculateSelectedPair() {
    try {
      if (groupA == null || groupB == null) {
        throw ArgumentError('Please select two groups.');
      }

      if (groupA == groupB) {
        throw ArgumentError('Please select two different groups.');
      }

      final result = calculatePair(groupA!, groupB!);

      setState(() {
        results = [result];
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll("Invalid argument(s): ", "");
        results = [];
      });
    }
  }

  void calculateAllPairs() {
    try {
      if (groupValues.length < 2) {
        throw ArgumentError('At least two groups are required.');
      }

      final newResults = <BatchResult>[];

      for (int i = 0; i < groupValues.length; i++) {
        for (int j = i + 1; j < groupValues.length; j++) {
          try {
            newResults.add(calculatePair(groupValues[i], groupValues[j]));
          } catch (_) {
            // Skip bad pairs silently for MVP.
          }
        }
      }

      if (newResults.isEmpty) {
        throw ArgumentError('No valid treatment pairs found.');
      }

      setState(() {
        results = newResults;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll("Invalid argument(s): ", "");
        results = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final beta = 1 - power;

    return Scaffold(
      appBar: AppBar(title: const Text("Bulk Treatment Analysis")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionCard(
                  title: "1. Paste CSV Data",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Accepted format: one grouping column such as treatment, and one numeric outcome column such as yield, protein, ANUE, or CC_biomass.",
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: csvController,
                        minLines: 8,
                        maxLines: 14,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText:
                              "Paste CSV here...\nExample columns: Field,year,rep,treatment,Nrate,yield,protein,ANUE",
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ElevatedButton.icon(
                            onPressed: parseCsv,
                            icon: const Icon(Icons.table_chart),
                            label: const Text("Parse CSV"),
                          ),
                          OutlinedButton.icon(
                            onPressed: loadExampleCsv,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text("Load Example Data"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (headers.isNotEmpty)
                  _sectionCard(
                    title: "2. Select Analysis Columns",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Rows detected: ${rows.length}"),
                        Text("Columns detected: ${headers.join(', ')}"),
                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          initialValue: dependentColumn,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Dependent variable / outcome",
                          ),
                          items: numericColumns
                              .map(
                                (h) =>
                                    DropdownMenuItem(value: h, child: Text(h)),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              dependentColumn = v;
                              results = [];
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          initialValue: groupingColumn,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Grouping variable / treatment column",
                          ),
                          items: groupingColumns
                              .map(
                                (h) =>
                                    DropdownMenuItem(value: h, child: Text(h)),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              groupingColumn = v;
                              results = [];
                              refreshGroupValues();
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        if (groupValues.isNotEmpty)
                          Text("Groups detected: ${groupValues.join(', ')}"),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                if (groupValues.length >= 2)
                  _sectionCard(
                    title: "3. Choose Comparisons and Error Rates",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Selected-pair mode compares one treatment pair. All-pair mode runs every possible pairwise comparison.",
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: groupA,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Group A",
                                ),
                                items: groupValues
                                    .map(
                                      (g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  setState(() {
                                    groupA = v;
                                    results = [];
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: groupB,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Group B",
                                ),
                                items: groupValues
                                    .map(
                                      (g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  setState(() {
                                    groupB = v;
                                    results = [];
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Text("Alpha: ${alpha.toStringAsFixed(3)}"),
                        Slider(
                          value: alpha,
                          min: 0.01,
                          max: 0.20,
                          divisions: 190,
                          label: alpha.toStringAsFixed(3),
                          onChanged: (v) {
                            setState(() {
                              alpha = v;
                              results = [];
                            });
                          },
                        ),

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
                              results = [];
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ElevatedButton.icon(
                              onPressed: calculateSelectedPair,
                              icon: const Icon(Icons.compare_arrows),
                              label: const Text("Calculate Selected Pair"),
                            ),
                            OutlinedButton.icon(
                              onPressed: calculateAllPairs,
                              icon: const Icon(Icons.all_inclusive),
                              label: const Text("Calculate All Pairs"),
                            ),
                          ],
                        ),
                      ],
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

                if (results.isNotEmpty)
                  _sectionCard(
                    title: "4. Batch Results",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "n/group means required sample size for each treatment group.",
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text("Comparison")),
                              DataColumn(label: Text("Mean A")),
                              DataColumn(label: Text("Mean B")),
                              DataColumn(label: Text("Diff")),
                              DataColumn(label: Text("SD A")),
                              DataColumn(label: Text("SD B")),
                              DataColumn(label: Text("Effect Size")),
                              DataColumn(label: Text("n/group")),
                              DataColumn(label: Text("Total n")),
                            ],
                            rows: results.map((r) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(r.comparison)),
                                  DataCell(Text(r.mean1.toStringAsFixed(2))),
                                  DataCell(Text(r.mean2.toStringAsFixed(2))),
                                  DataCell(Text(r.diff.toStringAsFixed(2))),
                                  DataCell(Text(r.sd1.toStringAsFixed(2))),
                                  DataCell(Text(r.sd2.toStringAsFixed(2))),
                                  DataCell(
                                    Text(r.effectSize.toStringAsFixed(3)),
                                  ),
                                  DataCell(Text(r.nPerGroup.toString())),
                                  DataCell(Text(r.totalN.toString())),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
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
