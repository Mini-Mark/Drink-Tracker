class Achievement {
  final String id;
  final String name;
  final String description;
  final int coinReward;
  final bool isCompleted;
  final int progress; // current progress value
  final int target; // target value to complete
  final String type; // 'drink_count', 'consecutive_days', 'time_based', 'volume_based', 'variety', 'aquarium'
  final DateTime? completedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.coinReward,
    required this.isCompleted,
    required this.progress,
    required this.target,
    required this.type,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coinReward': coinReward,
      'isCompleted': isCompleted,
      'progress': progress,
      'target': target,
      'type': type,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      coinReward: json['coinReward'] as int,
      isCompleted: json['isCompleted'] as bool,
      progress: json['progress'] as int,
      target: json['target'] as int,
      type: json['type'] as String,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    int? coinReward,
    bool? isCompleted,
    int? progress,
    int? target,
    String? type,
    DateTime? completedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coinReward: coinReward ?? this.coinReward,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      type: type ?? this.type,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
