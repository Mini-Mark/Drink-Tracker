import 'package:flutter/material.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';

/// Welcome screen for new users introducing the app and its benefits
class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // App Icon/Logo placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop,
                  size: 60,
                  color: primary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Welcome Title
              const Text(
                'Welcome to\nDrink Tracker',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: title_xl,
                  fontWeight: FontWeight.bold,
                  color: dark,
                  height: 1.2,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'Stay hydrated with your personal aquarium companion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: title_md,
                  color: dark.withValues(alpha: 0.6),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Benefits List
              _buildBenefitItem(
                icon: Icons.track_changes,
                title: 'Track Your Hydration',
                description: 'Monitor your daily water intake with ease',
              ),
              
              const SizedBox(height: 24),
              
              _buildBenefitItem(
                icon: Icons.emoji_events,
                title: 'Unlock Achievements',
                description: 'Earn coins and rewards for staying hydrated',
              ),
              
              const SizedBox(height: 24),
              
              _buildBenefitItem(
                icon: Icons.pets,
                title: 'Grow Your Aquarium',
                description: 'Collect fish and decorations as you drink',
              ),
              
              const Spacer(),
              
              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/onboarding/age');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondary,
                    foregroundColor: white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Get Started',
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

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primary,
            size: 24,
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: title_md,
                  fontWeight: FontWeight.bold,
                  color: dark,
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
      ],
    );
  }
}
