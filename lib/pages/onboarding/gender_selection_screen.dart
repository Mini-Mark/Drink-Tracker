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

  Widget _buildGenderOption({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedGender == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = value;
          _errorMessage = null;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
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
              child: Text(
                label,
                style: TextStyle(
                  fontSize: title_md,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? primary : dark,
                ),
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
                'This helps us personalize your water goals',
                style: TextStyle(
                  fontSize: title_md,
                  color: dark.withValues(alpha: 0.6),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Gender Options
              _buildGenderOption(
                value: 'male',
                label: 'Male',
                icon: Icons.male,
              ),
              
              const SizedBox(height: 16),
              
              _buildGenderOption(
                value: 'female',
                label: 'Female',
                icon: Icons.female,
              ),
              
              const SizedBox(height: 16),
              
              _buildGenderOption(
                value: 'other',
                label: 'Other',
                icon: Icons.person,
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
