class Fish {
  final String id;
  final String name;
  final String imagePath;
  final int coinCost;
  final bool isPurchased;
  final DateTime? purchasedAt;

  Fish({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.coinCost,
    required this.isPurchased,
    this.purchasedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'coinCost': coinCost,
      'isPurchased': isPurchased,
      'purchasedAt': purchasedAt?.toIso8601String(),
    };
  }

  factory Fish.fromJson(Map<String, dynamic> json) {
    return Fish(
      id: json['id'] as String,
      name: json['name'] as String,
      imagePath: json['imagePath'] as String,
      coinCost: json['coinCost'] as int,
      isPurchased: json['isPurchased'] as bool,
      purchasedAt: json['purchasedAt'] != null
          ? DateTime.parse(json['purchasedAt'] as String)
          : null,
    );
  }

  Fish copyWith({
    String? id,
    String? name,
    String? imagePath,
    int? coinCost,
    bool? isPurchased,
    DateTime? purchasedAt,
  }) {
    return Fish(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      coinCost: coinCost ?? this.coinCost,
      isPurchased: isPurchased ?? this.isPurchased,
      purchasedAt: purchasedAt ?? this.purchasedAt,
    );
  }
}
