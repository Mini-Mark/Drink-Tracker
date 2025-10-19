class UserProfile {
  final int age;
  final String gender; // 'male', 'female', 'other'
  final double weight; // in kg
  final double height; // in cm
  final String exerciseFrequency; // 'sedentary', 'light', 'moderate', 'active', 'very_active'
  final int dailyWaterRequirement; // calculated in ml
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.exerciseFrequency,
    required this.dailyWaterRequirement,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'exerciseFrequency': exerciseFrequency,
      'dailyWaterRequirement': dailyWaterRequirement,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      age: json['age'] as int,
      gender: json['gender'] as String,
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      exerciseFrequency: json['exerciseFrequency'] as String,
      dailyWaterRequirement: json['dailyWaterRequirement'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  UserProfile copyWith({
    int? age,
    String? gender,
    double? weight,
    double? height,
    String? exerciseFrequency,
    int? dailyWaterRequirement,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      exerciseFrequency: exerciseFrequency ?? this.exerciseFrequency,
      dailyWaterRequirement: dailyWaterRequirement ?? this.dailyWaterRequirement,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
