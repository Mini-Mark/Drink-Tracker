import 'package:flutter/material.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';

/// Screen for selecting user's gender during onboarding
class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender;
  String? _errorMessage;

  bool _validateGender() {
    if (_selectedGender == null) {
      setState(() {
        _errorMessage = 'Please select your gender';
      });
      return false;
    }

    setState(() {
      _errorMessage = null;
    });
    return true;
  }

  void _handleNext() {
    if (_validateGender()) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final age = args?['age'] as int?;
      
      Navigator.pushNamed(
        context,
        '/onboarding/weight',
        arguments: {
          'age': age,
          'gender': _selectedGender,
        },
      );
    }
  }

  Widget _buildGenderCard({
    required String value,
    required String label,
    required IconData icon,
    required Color cardColor,
  }) {
    final isSelected = _selectedGender == value;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGender = value;
            _errorMessage = null;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? cardColor.withValues(alpha: 0.15) : white,
            border: Border.all(
              color: isSelected ? cardColor : grey.withValues(alpha: 0.3),
              width: isSelected ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected ? [
              BoxShadow(
                color: cardColor.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ] : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isSelected ? cardColor : grey.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? white : dark.withValues(alpha: 0.5),
                  size: 50,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                label,
                style: TextStyle(
                  fontSize: title_lg,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? cardColor : dark.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
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
                value: 0.4,
                backgroundColor: grey.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(primary),
                minHeight: 4,
              ),
              
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'What is your gender?',
                style: TextStyle(
                  fontSize: title_xl,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'This helps us calculate accurate water values',
                style: TextStyle(
                  fontSize: title_md,
                  color: dark.withValues(alpha: 0.6),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Gender Cards
              Expanded(
                child: Row(
                  children: [
                    _buildGenderCard(
                      value: 'male',
                      label: 'Male',
                      icon: Icons.male,
                      cardColor: const Color(0xFF4A90E2),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    _buildGenderCard(
                      value: 'female',
                      label: 'Female',
                      icon: Icons.female,
                      cardColor: const Color(0xFFE91E63),
                    ),
                  ],
                ),
              ),
              
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: text_md,
                    color: danger,
                  ),
                ),
              ],
              
              const Spacer(),
              
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
