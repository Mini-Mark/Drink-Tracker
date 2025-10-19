import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';

/// Screen for collecting user's age during onboarding
class AgeInputScreen extends StatefulWidget {
  const AgeInputScreen({Key? key}) : super(key: key);

  @override
  State<AgeInputScreen> createState() => _AgeInputScreenState();
}

class _AgeInputScreenState extends State<AgeInputScreen> {
  final TextEditingController _ageController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  bool _validateAge() {
    final ageText = _ageController.text.trim();
    
    if (ageText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your age';
      });
      return false;
    }

    final age = int.tryParse(ageText);
    if (age == null) {
      setState(() {
        _errorMessage = 'Please enter a valid number';
      });
      return false;
    }

    if (age < 1 || age > 120) {
      setState(() {
        _errorMessage = 'Age must be between 1 and 120';
      });
      return false;
    }

    setState(() {
      _errorMessage = null;
    });
    return true;
  }

  void _handleNext() {
    if (_validateAge()) {
      final age = int.parse(_ageController.text.trim());
      Navigator.pushNamed(
        context,
        '/onboarding/gender',
        arguments: {'age': age},
      );
    }
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
                value: 0.2,
                backgroundColor: grey.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(primary),
                minHeight: 4,
              ),
              
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'How old are you?',
                style: TextStyle(
                  fontSize: title_xl,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'This helps us calculate your daily water needs',
                style: TextStyle(
                  fontSize: title_md,
                  color: dark.withValues(alpha: 0.6),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Age Input Field
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                style: const TextStyle(
                  fontSize: title_lg,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your age',
                  hintStyle: TextStyle(
                    fontSize: title_lg,
                    color: dark.withValues(alpha: 0.3),
                  ),
                  suffixText: 'years',
                  suffixStyle: TextStyle(
                    fontSize: title_md,
                    color: dark.withValues(alpha: 0.6),
                  ),
                  errorText: _errorMessage,
                  errorStyle: const TextStyle(
                    fontSize: text_md,
                    color: danger,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: grey.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: primary, width: 2),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: danger, width: 2),
                  ),
                  focusedErrorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: danger, width: 2),
                  ),
                ),
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
                onSubmitted: (_) => _handleNext(),
              ),
              
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
