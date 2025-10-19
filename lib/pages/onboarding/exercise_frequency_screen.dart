import 'package:flutter/material.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';

/// Screen for selecting user's exercise frequency during onboarding
class ExerciseFrequencyScreen extends StatefulWidget {
  const ExerciseFrequencyScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseFrequencyScreen> createState() => _ExerciseFrequencyScreenState();
}

class _ExerciseFrequencyScreenState extends State<ExerciseFrequencyScreen> {
  String? _selectedFrequency;
  String? _errorMessage;

  final Map<String, Map<String, dynamic>> _exerciseOptions = {
    'sedentary': {
      'label': 'Sedentary',
      'description': 'Little or no exercise',
      'icon': Icons.weekend,
    },
    'light': {
      'label': 'Light',
      'description': 'Exercise 1-3 days/week',
      'icon': Icons.directions_walk,
    },
    'moderate': {
      'label': 'Moderate',
      'description': 'Exercise 3-5 days/week',
      'icon': Icons.directions_run,
    },
    'active': {
      'label': 'Active',
      'description': 'Exercise 6-7 days/week',
      'icon': Icons.fitness_center,
    },
    'very_active': {
      'label': 'Very Active',
      'description': 'Intense exercise daily',
      'icon': Icons.sports_gymnastics,
    },
  };

  bool _validateFrequency() {
    if (_selectedFrequency == null) {
      setState(() {
        _errorMessage = 'Please select your exercise frequency';
      });
      return false;
    }

    setState(() {
      _errorMessage = null;
    });
    return true;
  }

  void _handleNext() {
    if (_validateFrequency()) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final age = args?['age'] as int?;
      final gender = args?['gender'] as String?;
      final weight = args?['weight'] as double?;
      final height = args?['height'] as double?;
      
      Navigator.pushNamed(
        context,
        '/onboarding/summary',
        arguments: {
          'age': age,
          'gender': gender,
          'weight': weight,
          'height': height,
          'exerciseFrequency': _selectedFrequency,
        },
      );
    }
  }

  Widget _buildExerciseOption({
    required String value,
    required String label,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedFrequency == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFrequency = value;
          _errorMessage = null;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primary.withValues(alpha: 0.1) : white,
          border: Border.all(
            color: isSelected ? primary : grey.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? primary : grey.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? white : dark.withValues(alpha: 0.6),
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: title_md,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? primary : dark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: text_md,
                      color: dark.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: dark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: 1.0,
                backgroundColor: grey.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(primary),
                minHeight: 4,
              ),
              
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'How active are you?',
                style: TextStyle(
                  fontSize: title_xl,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Your activity level affects your hydration needs',
                style: TextStyle(
                  fontSize: title_md,
                  color: dark.withValues(alpha: 0.6),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Exercise Options
              Expanded(
                child: ListView(
                  children: [
                    ..._exerciseOptions.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildExerciseOption(
                          value: entry.key,
                          label: entry.value['label'],
                          description: entry.value['description'],
                          icon: entry.value['icon'],
                        ),
                      );
                    }),
                    
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: text_md,
                          color: danger,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Next Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondary,
                    foregroundColor: white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: title_md,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
