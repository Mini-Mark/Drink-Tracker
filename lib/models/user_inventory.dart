class UserInventory {
  final int coinBalance;
  final List<String> purchasedFishIds;
  final List<String> purchasedDecorationIds;
  final List<String> activeFishIds; // fish currently displayed in aquarium
  final List<String> activeDecorationIds; // decorations currently displayed

  UserInventory({
    required this.coinBalance,
    required this.purchasedFishIds,
    required this.purchasedDecorationIds,
    required this.activeFishIds,
    required this.activeDecorationIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'coinBalance': coinBalance,
      'purchasedFishIds': purchasedFishIds,
      'purchasedDecorationIds': purchasedDecorationIds,
      'activeFishIds': activeFishIds,
      'activeDecorationIds': activeDecorationIds,
    };
  }

  factory UserInventory.fromJson(Map<String, dynamic> json) {
    return UserInventory(
      coinBalance: json['coinBalance'] as int,
      purchasedFishIds: List<String>.from(json['purchasedFishIds'] as List),
      purchasedDecorationIds: List<String>.from(json['purchasedDecorationIds'] as List),
      activeFishIds: List<String>.from(json['activeFishIds'] as List),
      activeDecorationIds: List<String>.from(json['activeDecorationIds'] as List),
    );
  }

  UserInventory copyWith({
    int? coinBalance,
    List<String>? purchasedFishIds,
    List<String>? purchasedDecorationIds,
    List<String>? activeFishIds,
    List<String>? activeDecorationIds,
  }) {
    return UserInventory(
      coinBalance: coinBalance ?? this.coinBalance,
      purchasedFishIds: purchasedFishIds ?? this.purchasedFishIds,
      purchasedDecorationIds: purchasedDecorationIds ?? this.purchasedDecorationIds,
      activeFishIds: activeFishIds ?? this.activeFishIds,
      activeDecorationIds: activeDecorationIds ?? this.activeDecorationIds,
    );
  }
}
