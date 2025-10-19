import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';

/// Screen for collecting user's weight during onboarding
class WeightInputScreen extends StatefulWidget {
  const WeightInputScreen({Key? key}) : super(key: key);

  @override
  State<WeightInputScreen> createState() => _WeightInputScreenState();
}

class _WeightInputScreenState extends State<WeightInputScreen> {
  final TextEditingController _weightController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  bool _validateWeight() {
    final weightText = _weightController.text.trim();
    
    if (weightText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your weight';
      });
      return false;
    }

    final weight = double.tryParse(weightText);
    if (weight == null) {
      setState(() {
        _errorMessage = 'Please enter a valid number';
      });
      return false;
    }

    if (weight < 20 || weight > 300) {
      setState(() {
        _errorMessage = 'Weight must be between 20 and 300 kg';
      });
      return false;
    }

    setState(() {
      _errorMessage = null;
    });
    return true;
  }

  void _handleNext() {
    if (_validateWeight()) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final age = args?['age'] as int?;
      final gender = args?['gender'] as String?;
      final weight = double.parse(_weightController.text.trim());
      
      Navigator.pushNamed(
        context,
        '/onboarding/height',
        arguments: {
          'age': age,
          'gender': gender,
          'weight': weight,
        },
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
                value: 0.6,
                backgroundColor: grey.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(primary),
                minHeight: 4,
              ),
              
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'What is your weight?',
                style: TextStyle(
                  fontSize: title_xl,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'We use this to calculate your hydration needs',
                style: TextStyle(
                  fontSize: title_md,
                  color: dark.withValues(alpha: 0.6),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Weight Input Field
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                ],
                style: const TextStyle(
                  fontSize: title_lg,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your weight',
                  hintStyle: TextStyle(
                    fontSize: title_lg,
                    color: dark.withValues(alpha: 0.3),
                  ),
                  suffixText: 'kg',
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
