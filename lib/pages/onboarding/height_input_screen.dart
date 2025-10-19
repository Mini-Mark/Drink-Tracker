import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';

/// Screen for collecting user's height during onboarding
class HeightInputScreen extends StatefulWidget {
  const HeightInputScreen({Key? key}) : super(key: key);

  @override
  State<HeightInputScreen> createState() => _HeightInputScreenState();
}

class _HeightInputScreenState extends State<HeightInputScreen> {
  final TextEditingController _heightController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _heightController.dispose();
    super.dispose();
  }

  bool _validateHeight() {
    final heightText = _heightController.text.trim();
    
    if (heightText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your height';
      });
      return false;
    }

    final height = double.tryParse(heightText);
    if (height == null) {
      setState(() {
        _errorMessage = 'Please enter a valid number';
      });
      return false;
    }

    if (height < 50 || height > 250) {
      setState(() {
        _errorMessage = 'Height must be between 50 and 250 cm';
      });
      return false;
    }

    setState(() {
      _errorMessage = null;
    });
    return true;
  }

  void _handleNext() {
    if (_validateHeight()) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final age = args?['age'] as int?;
      final gender = args?['gender'] as String?;
      final weight = args?['weight'] as double?;
      final height = double.parse(_heightController.text.trim());
      
      Navigator.pushNamed(
        context,
        '/onboarding/exercise',
        arguments: {
          'age': age,
          'gender': gender,
          'weight': weight,
          'height': height,
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
                value: 0.8,
                backgroundColor: grey.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(primary),
                minHeight: 4,
              ),
              
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'What is your height?',
                style: TextStyle(
                  fontSize: title_xl,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Almost done! Just a few more details',
                style: TextStyle(
                  fontSize: title_md,
                  color: dark.withValues(alpha: 0.6),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Height Input Field
              TextField(
                controller: _heightController,
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
                  hintText: 'Enter your height',
                  hintStyle: TextStyle(
                    fontSize: title_lg,
                    color: dark.withValues(alpha: 0.3),
                  ),
                  suffixText: 'cm',
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
