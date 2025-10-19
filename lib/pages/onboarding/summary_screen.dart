import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';
import 'package:drinktracker/providers/app_state.dart';

/// Summary screen showing calculated water requirement and completing onboarding
class SummaryScreen extends StatefulWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool _isLoading = false;
  int? _calculatedRequirement;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _calculateWaterRequirement();
  }

  void _calculateWaterRequirement() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    if (args != null) {
      final age = args['age'] as int?;
      final gender = args['gender'] as String?;
      final weight = args['weight'] as double?;
      final exerciseFrequency = args['exerciseFrequency'] as String?;

      if (age != null && gender != null && weight != null && exerciseFrequency != null) {
        // Calculate using the same formula as ProfileService
        double baseRequirement = weight * 33;

        // Gender adjustment
        if (gender.toLowerCase() == 'male') {
          baseRequirement *= 1.1;
        }

        // Age adjustment
        if (age >= 65) {
          baseRequirement *= 0.95;
        }

        // Exercise frequency adjustment
        double exerciseAdjustment = 0;
        switch (exerciseFrequency.toLowerCase()) {
          case 'sedentary':
            exerciseAdjustment = 0;
            break;
          case 'light':
            exerciseAdjustment = 300;
            break;
          case 'moderate':
            exerciseAdjustment = 500;
            break;
          case 'active':
            exerciseAdjustment = 750;
            break;
          case 'very_active':
            exerciseAdjustment = 1000;
            break;
        }

        final totalRequirement = baseRequirement + exerciseAdjustment;
        setState(() {
          _calculatedRequirement = ((totalRequirement / 50).round() * 50).toInt();
        });
      }
    }
  }

  String _getGenderLabel(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'other':
        return 'Other';
      default:
        return gender;
    }
  }

  String _getExerciseLabel(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'sedentary':
        return 'Sedentary';
      case 'light':
        return 'Light';
      case 'moderate':
        return 'Moderate';
      case 'active':
        return 'Active';
      case 'very_active':
        return 'Very Active';
      default:
        return frequency;
    }
  }

  Future<void> _completeSetup() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    if (args == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Missing profile data'),
          backgroundColor: danger,
        ),
      );
      return;
    }

    final age = args['age'] as int?;
    final gender = args['gender'] as String?;
    final weight = args['weight'] as double?;
    final height = args['height'] as double?;
    final exerciseFrequency = args['exerciseFrequency'] as String?;

    if (age == null || gender == null || weight == null || 
        height == null || exerciseFrequency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Incomplete profile data'),
          backgroundColor: danger,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      
      // Create profile through AppState
      await appState.createProfile(
        age: age,
        gender: gender,
        weight: weight,
        height: height,
        exerciseFrequency: exerciseFrequency,
      );

      // Navigate to home screen and remove all previous routes
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing setup: $e'),
            backgroundColor: danger,
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primary,
              size: 20,
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
                    fontSize: text_sm,
                    color: dark.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: title_md,
                    fontWeight: FontWeight.w600,
                    color: dark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final age = args?['age'] as int?;
    final gender = args?['gender'] as String?;
    final weight = args?['weight'] as double?;
    final height = args?['height'] as double?;
    final exerciseFrequency = args?['exerciseFrequency'] as String?;

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: dark),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator (complete)
              LinearProgressIndicator(
                value: 1.0,
                backgroundColor: grey.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(primary),
                minHeight: 4,
              ),
              
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'Your Daily Goal',
                style: TextStyle(
                  fontSize: title_xl,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Based on your profile, here\'s your personalized hydration goal',
                style: TextStyle(
                  fontSize: title_md,
                  color: dark.withValues(alpha: 0.6),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Water requirement display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primary, secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.water_drop,
                      color: white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    if (_calculatedRequirement != null) ...[
                      Text(
                        '$_calculatedRequirement ml',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_calculatedRequirement! / 1000).toStringAsFixed(1)} liters per day',
                        style: TextStyle(
                          fontSize: title_md,
                          color: white.withValues(alpha: 0.9),
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Calculating...',
                        style: TextStyle(
                          fontSize: title_lg,
                          color: white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Profile summary
              const Text(
                'Your Profile',
                style: TextStyle(
                  fontSize: title_lg,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView(
                  children: [
                    if (age != null)
                      _buildInfoRow('Age', '$age years', Icons.cake),
                    
                    const SizedBox(height: 12),
                    
                    if (gender != null)
                      _buildInfoRow('Gender', _getGenderLabel(gender), Icons.person),
                    
                    const SizedBox(height: 12),
                    
                    if (weight != null)
                      _buildInfoRow('Weight', '${weight.toStringAsFixed(1)} kg', Icons.monitor_weight),
                    
                    const SizedBox(height: 12),
                    
                    if (height != null)
                      _buildInfoRow('Height', '${height.toStringAsFixed(1)} cm', Icons.height),
                    
                    const SizedBox(height: 12),
                    
                    if (exerciseFrequency != null)
                      _buildInfoRow('Activity Level', _getExerciseLabel(exerciseFrequency), Icons.fitness_center),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Complete Setup Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _completeSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondary,
                    foregroundColor: white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Complete Setup',
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
