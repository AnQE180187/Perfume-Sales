import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/main_shell.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentStep = 0;
  final List<String> _questions = [
    "What occasion is this scent for?",
    "What is your preferred budget?",
    "Which scent family do you adore?",
    "Desired longevity of the fragrance?",
    "Describe your personality in one word."
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
        decoration: BoxDecoration(
          gradient: AppTheme.getLuxuryGradient(brightness),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            Row(
              children: List.generate(5, (index) => Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(right: 4),
                  color: index <= _currentStep ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.outline,
                ),
              )),
            ),
            const SizedBox(height: 40),
            Text(
              "STEP ${_currentStep + 1} OF 5",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 20),
            Text(
              _questions[_currentStep],
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 60),
            
            // Options (Example for step 0)
            Expanded(
              child: ListView(
                children: [
                  QuizOption(title: "Grand Evening Gala", icon: Icons.nightlife, isSelected: false, onTap: _nextStep),
                  QuizOption(title: "Professional Workplace", icon: Icons.business_center, isSelected: false, onTap: _nextStep),
                  QuizOption(title: "Casual Sunday Brunch", icon: Icons.wb_sunny, isSelected: false, onTap: _nextStep),
                  QuizOption(title: "Intimate Date Night", icon: Icons.favorite, isSelected: false, onTap: _nextStep),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainShell()),
      );
    }
  }
}

class QuizOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const QuizOption({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: InkWell(
        onTap: onTap,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          opacity: 0.1,
          borderRadius: 8, // Rounded aesthetic
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 24),
              const SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
