# StatScope

An interactive statistical learning and experimental planning tool built with Flutter.

## Live Demo

🔗 https://safat99.github.io/statscope/

## Project Overview

StatScope is an educational and research-oriented application that helps users understand important concepts in statistical hypothesis testing through interactive visualizations and practical calculators.

I built this project during my Spring 2026 Graduate Research Assistantship (GRA) at Montana State University under the direction of [Dr. Anthony Hartshorn](https://landresources.montana.edu/directory/faculty/1524160/anthony-hartshorn). The main goal of this project is to help students learn concepts such as Type I error, Type II error, statistical power, effect size, and sample size planning in a more visual and interactive way.

Besides learning statistical concepts, the project also includes tools that can assist researchers during study planning and treatment comparison analysis.

The application is built using Flutter and is designed to support Web, Android, and iOS platforms.

---

## Main Features

### Statistical Error Simulator

This module provides an interactive visualization of hypothesis testing concepts.

Users can explore:

* Null Hypothesis (H₀)
* Alternative Hypothesis (H₁)
* Type I Error (α)
* Type II Error (β)
* False Positive
* False Negative
* Statistical Power
* Distribution overlap

Different parameters can be adjusted in real time to observe how statistical decisions change.

### Learning Mode

The learning mode explains the theory behind the simulator using simple examples and visual demonstrations.

Topics currently include:

* Hypothesis testing
* Null and alternative hypotheses
* p-values
* Alpha (α)
* Beta (β)
* Type I and Type II errors
* Statistical power
* Effect size
* Sample size planning

The goal of this section is to make statistical concepts easier to understand for students who are learning these topics for the first time.

### Sample Size Calculator

This module helps users estimate the minimum sample size required before conducting a study.

The calculator allows users to explore how changes in:

* Effect size
* Standard deviation
* Alpha level
* Statistical power

can affect the number of observations needed for an experiment.

This helps users understand the tradeoff between statistical confidence and study cost.

### Bulk Treatment Analysis

The Bulk Treatment Analysis module is designed for treatment comparison and experimental planning.

Users can:

* Paste CSV datasets directly into the application
* Select grouping variables
* Select outcome variables
* Compare specific treatment pairs
* Compare all treatment pairs automatically
* Calculate effect sizes
* Estimate required sample size per treatment group
* Generate sample size planning tables

This feature can help researchers evaluate whether a study is adequately powered and estimate the amount of replication needed for future experiments.

---

## Screenshots

### Home Screen

![Home Screen](assets/readme/home_screen.png)

### Statistical Error Simulator

![Error Simulator](assets/readme/error_simulator.png)

### Learning Mode

![Learning Mode](assets/readme/learning_mode.png)

### Sample Size Calculator

![Sample Size Calculator](assets/readme/sample_size_calculator.png)

### Bulk Treatment Analysis

![Bulk Treatment Analysis](assets/readme/bulk_treatment_analysis.png)

---

## Why I Built This Project

While learning statistical hypothesis testing, I often felt that many concepts were difficult to understand from formulas alone.

Terms such as Type I error, Type II error, alpha, beta, power, and effect size are important in research, but they are often taught using static examples. I wanted to create a tool where users could directly interact with these concepts and immediately see how different parameters influence statistical decisions.

The project later expanded to include sample size calculators and treatment analysis tools that can also support future research planning.

---

## Technologies Used

* Flutter
* Dart
* Material Design
* Interactive data visualization
* Statistical and power analysis calculations

---

## Getting Started

### Clone the Repository

```bash
git clone https://github.com/Safat99/statscope.git
```

### Move into the Project Directory

```bash
cd statscope
```

### Install Dependencies

```bash
flutter pub get
```

### Run the Application

```bash
flutter run
```

### Build for Web

```bash
flutter build web
```

---

## Project Documentation

Additional documentation and tutorial articles are being developed and will be expanded over time.

Current project documents:

* `project_docs/tutorials.md`
* `project_docs/bulk_analysis.md`

Future updates will include:

* Step-by-step tutorials
* Animated explanations
* GIF demonstrations
* Statistical background notes
* Practical examples and walkthroughs

---

## Future Plans

Some planned improvements include:

* Detailed tutorial articles
* GIF-based learning demonstrations
* Additional statistical calculators
* Excel file support
* Exporting analysis results
* More study design options
* Improved documentation
* Additional educational content for statistics students

---

## Acknowledgements

I would like to thank Dr. Anthony Hartshorn at Montana State University for his guidance, feedback, and project direction throughout the development of this application.

This project was developed as part of my Spring 2026 Graduate Research Assistantship (GRA).

I would also like to acknowledge the educational resources, statistical learning materials, and open-source tools that helped me understand many of the concepts implemented in this project.

---

## License

This project is licensed under the MIT License.

See the LICENSE file for more information.
