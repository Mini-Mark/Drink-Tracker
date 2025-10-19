class DrinkEntry {
  final String id; // UUID
  final int drinkId; // reference to drink type
  final int mlAmount;
  final DateTime timestamp;
  final String date; // formatted date for grouping (YYYY-MM-DD)

  DrinkEntry({
    required this.id,
    required this.drinkId,
    required this.mlAmount,
    required this.timestamp,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'drinkId': drinkId,
      'mlAmount': mlAmount,
      'timestamp': timestamp.toIso8601String(),
      'date': date,
    };
  }

  factory DrinkEntry.fromJson(Map<String, dynamic> json) {
    return DrinkEntry(
      id: json['id'] as String,
      drinkId: json['drinkId'] as int,
      mlAmount: json['mlAmount'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      date: json['date'] as String,
    );
  }

  DrinkEntry copyWith({
    String? id,
    int? drinkId,
    int? mlAmount,
    DateTime? timestamp,
    String? date,
  }) {
    return DrinkEntry(
      id: id ?? this.id,
      drinkId: drinkId ?? this.drinkId,
      mlAmount: mlAmount ?? this.mlAmount,
      timestamp: timestamp ?? this.timestamp,
      date: date ?? this.date,
    );
  }
}
