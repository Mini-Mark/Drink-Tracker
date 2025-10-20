import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';
import 'package:drinktracker/providers/app_state.dart';
import 'package:drinktracker/models/user_profile.dart';
import '../widgets/animated_wave.dart';

/// Settings screen displaying current profile information and daily water requirement
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isSaving = false;

  // Controllers for editable fields
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  String _selectedGender = 'male';
  String _selectedExerciseFrequency = 'sedentary';

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController();
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _initializeControllers(UserProfile profile) {
    if (_ageController.text.isEmpty) {
      _ageController.text = profile.age.toString();
      _weightController.text = profile.weight.toStringAsFixed(1);
      _selectedGender = profile.gender;
      _selectedExerciseFrequency = profile.exerciseFrequency;
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset to original values if canceling
        final profile =
            Provider.of<AppState>(context, listen: false).userProfile;
        if (profile != null) {
          _ageController.text = profile.age.toString();
          _weightController.text = profile.weight.toStringAsFixed(1);
          _selectedGender = profile.gender;
          _selectedExerciseFrequency = profile.exerciseFrequency;
        }
      }
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final currentProfile = appState.userProfile;

      if (currentProfile == null) {
        throw Exception('No profile found');
      }

      // Create updated profile
      final updatedProfile = UserProfile(
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        weight: double.parse(_weightController.text),
        exerciseFrequency: _selectedExerciseFrequency,
        dailyWaterRequirement: 0, // Will be recalculated
        createdAt: currentProfile.createdAt,
        updatedAt: DateTime.now(),
      );

      await appState.updateProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
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

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
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

  Widget _buildEditableTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.number,
    String? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
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
                  label,
                  style: TextStyle(
                    fontSize: text_sm,
                    color: dark.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  validator: validator,
                  style: const TextStyle(
                    fontSize: title_md,
                    fontWeight: FontWeight.w600,
                    color: dark,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    suffixText: suffix,
                    suffixStyle: TextStyle(
                      fontSize: text_md,
                      color: dark.withValues(alpha: 0.6),
                    ),
                  ),
                  inputFormatters: [
                    if (keyboardType == TextInputType.number)
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,1}')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableDropdown({
    required String label,
    required String value,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
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
                  label,
                  style: TextStyle(
                    fontSize: text_sm,
                    color: dark.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: value,
                  items: items,
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontSize: title_md,
                    fontWeight: FontWeight.w600,
                    color: dark,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: primary),
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
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: title_lg,
            fontWeight: FontWeight.bold,
            color: dark,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: primary),
              onPressed: _toggleEditMode,
              tooltip: 'Edit Profile',
            )
          else
            TextButton(
              onPressed: _isSaving ? null : _saveChanges,
              child: const Text(
                'Save',
                style: TextStyle(color: success),
              ),
            ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final profile = appState.userProfile;

          if (profile == null) {
            return const Center(
              child: Text(
                'No profile data available',
                style: TextStyle(
                  fontSize: title_md,
                  color: dark,
                ),
              ),
            );
          }

          _initializeControllers(profile);

          return Form(
            key: _formKey,
            child: Column(
              children: [
                // Scrollable Profile Information Section
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Profile Information',
                                style: TextStyle(
                                  fontSize: title_lg,
                                  fontWeight: FontWeight.bold,
                                  color: dark,
                                ),
                              ),
                              if (_isEditing)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Editing Mode',
                                    style: TextStyle(
                                      fontSize: text_sm,
                                      color: primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Age
                          if (_isEditing)
                            _buildEditableTextField(
                              label: 'Age',
                              controller: _ageController,
                              icon: Icons.cake,
                              suffix: 'years',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your age';
                                }
                                final age = int.tryParse(value);
                                if (age == null) {
                                  return 'Please enter a valid number';
                                }
                                if (age < 1 || age > 120) {
                                  return 'Age must be between 1 and 120';
                                }
                                return null;
                              },
                            )
                          else
                            _buildInfoCard(
                              'Age',
                              '${profile.age} years',
                              Icons.cake,
                            ),
                          const SizedBox(height: 12),

                          // Gender
                          if (_isEditing)
                            _buildEditableDropdown(
                              label: 'Gender',
                              value: _selectedGender,
                              icon: Icons.person,
                              items: const [
                                DropdownMenuItem(
                                    value: 'male', child: Text('Male')),
                                DropdownMenuItem(
                                    value: 'female', child: Text('Female')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                }
                              },
                            )
                          else
                            _buildInfoCard(
                              'Gender',
                              _getGenderLabel(profile.gender),
                              Icons.person,
                            ),
                          const SizedBox(height: 12),

                          // Weight
                          if (_isEditing)
                            _buildEditableTextField(
                              label: 'Weight',
                              controller: _weightController,
                              icon: Icons.monitor_weight,
                              suffix: 'kg',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your weight';
                                }
                                final weight = double.tryParse(value);
                                if (weight == null) {
                                  return 'Please enter a valid number';
                                }
                                if (weight < 20 || weight > 300) {
                                  return 'Weight must be between 20 and 300 kg';
                                }
                                return null;
                              },
                            )
                          else
                            _buildInfoCard(
                              'Weight',
                              '${profile.weight.toStringAsFixed(1)} kg',
                              Icons.monitor_weight,
                            ),
                          const SizedBox(height: 12),

                          // Exercise Frequency
                          if (_isEditing)
                            _buildEditableDropdown(
                              label: 'Activity Level',
                              value: _selectedExerciseFrequency,
                              icon: Icons.fitness_center,
                              items: const [
                                DropdownMenuItem(
                                  value: 'sedentary',
                                  child: Text('Sedentary'),
                                ),
                                DropdownMenuItem(
                                  value: 'light',
                                  child: Text('Light'),
                                ),
                                DropdownMenuItem(
                                  value: 'moderate',
                                  child: Text('Moderate'),
                                ),
                                DropdownMenuItem(
                                  value: 'active',
                                  child: Text('Active'),
                                ),
                                DropdownMenuItem(
                                  value: 'very_active',
                                  child: Text('Very Active'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedExerciseFrequency = value;
                                  });
                                }
                              },
                            )
                          else
                            _buildInfoCard(
                              'Activity Level',
                              _getExerciseLabel(profile.exerciseFrequency),
                              Icons.fitness_center,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Daily Water Requirement with Wave Animation - Fixed at top, full width
                SizedBox(
                  width: double.infinity,
                  height: 240,
                  child: Stack(
                    children: [
                      // Wave animation at the bottom
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 240,
                        child: AnimatedWaveAnimation(
                          heightPercent: 100,
                          callback: () {},
                          color: primary,
                        ),
                      ),

                      // Text content at the top
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 44),
                              Text(
                                '${profile.dailyWaterRequirement} ml',
                                style: const TextStyle(
                                  fontSize: title_xl,
                                  fontWeight: FontWeight.bold,
                                  color: dark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(profile.dailyWaterRequirement / 1000).toStringAsFixed(1)} liters per day',
                                style: TextStyle(
                                  fontSize: text_md,
                                  color: dark.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
