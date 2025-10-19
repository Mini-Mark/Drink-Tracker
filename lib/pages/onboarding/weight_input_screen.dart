import 'package:flutter/material.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';

/// Screen for collecting user's weight during onboarding
class WeightInputScreen extends StatefulWidget {
  const WeightInputScreen({Key? key}) : super(key: key);

  @override
  State<WeightInputScreen> createState() => _WeightInputScreenState();
}

class _WeightInputScreenState extends State<WeightInputScreen> {
  late FixedExtentScrollController _scrollController;
  int _selectedWeight = 70;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(initialItem: _selectedWeight - 20);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleNext() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final age = args?['age'] as int?;
    final gender = args?['gender'] as String?;
    
    Navigator.pushNamed(
      context,
      '/onboarding/exercise',
      arguments: {
        'age': age,
        'gender': gender,
        'weight': _selectedWeight.toDouble(),
      },
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
                value: 0.75,
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
              
              const SizedBox(height: 24),
              
              // Vertical Number Picker
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Selection indicator
                    Container(
                      height: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primary, width: 2),
                      ),
                    ),
                    
                    // Number picker
                    ListWheelScrollView.useDelegate(
                      controller: _scrollController,
                      itemExtent: 80,
                      perspective: 0.003,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedWeight = index + 20;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 281, // 20 to 300 kg
                        builder: (context, index) {
                          final weight = index + 20;
                          final isSelected = weight == _selectedWeight;
                          
                          return Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  weight.toString(),
                                  style: TextStyle(
                                    fontSize: isSelected ? 48 : 32,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? primary : dark.withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'kg',
                                  style: TextStyle(
                                    fontSize: isSelected ? title_lg : title_md,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected ? primary.withValues(alpha: 0.8) : dark.withValues(alpha: 0.3),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
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
