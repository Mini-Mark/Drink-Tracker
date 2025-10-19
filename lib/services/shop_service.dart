import '../repositories/local_storage_repository.dart';
import '../models/fish.dart';
import '../models/decoration.dart';
import '../models/user_inventory.dart';
import 'coin_service.dart';

class ShopService {
  final LocalStorageRepository _repository;
  final CoinService _coinService;

  ShopService(this._repository, this._coinService);

  /// Get the fish catalog from storage
  /// If catalog doesn't exist, initialize with default fish
  List<Fish> getFishCatalog() {
    try {
      List<Fish> catalog = _repository.getFishCatalog();
      
      // Initialize default catalog if empty
      if (catalog.isEmpty) {
        catalog = _initializeDefaultFishCatalog();
        _repository.saveFishCatalog(catalog);
      }
      
      return catalog;
    } catch (e) {
      throw Exception('Failed to get fish catalog: $e');
    }
  }

  /// Get the decoration catalog from storage
  /// If catalog doesn't exist, initialize with default decorations
  List<Decoration> getDecorationCatalog() {
    try {
      List<Decoration> catalog = _repository.getDecorationCatalog();
      
      // Initialize default catalog if empty
      if (catalog.isEmpty) {
        catalog = _initializeDefaultDecorationCatalog();
        _repository.saveDecorationCatalog(catalog);
      }
      
      return catalog;
    } catch (e) {
      throw Exception('Failed to get decoration catalog: $e');
    }
  }

  /// Purchase a fish with coin validation
  /// Returns true if purchase successful, false if insufficient coins or already purchased
  Future<bool> purchaseFish(String fishId) async {
    try {
      final fishCatalog = getFishCatalog();
      final fishIndex = fishCatalog.indexWhere((f) => f.id == fishId);
      
      if (fishIndex == -1) {
        throw ArgumentError('Fish with id $fishId not found');
      }

      final fish = fishCatalog[fishIndex];
      
      // Check if already purchased
      if (fish.isPurchased) {
        return false;
      }

      // Check if user can afford
      if (!canAfford(fish.coinCost)) {
        return false;
      }

      // Deduct coins
      final deductSuccess = await _coinService.deductCoins(fish.coinCost);
      if (!deductSuccess) {
        return false;
      }

      // Update fish catalog
      final updatedFish = fish.copyWith(
        isPurchased: true,
        purchasedAt: DateTime.now(),
      );
      fishCatalog[fishIndex] = updatedFish;
      await _repository.saveFishCatalog(fishCatalog);

      // Update user inventory
      final inventory = _repository.getUserInventory() ?? _createDefaultInventory();
      final updatedInventory = inventory.copyWith(
        purchasedFishIds: [...inventory.purchasedFishIds, fishId],
      );
      await _repository.saveUserInventory(updatedInventory);

      return true;
    } catch (e) {
      throw Exception('Failed to purchase fish: $e');
    }
  }

  /// Purchase a decoration with coin validation
  /// Returns true if purchase successful, false if insufficient coins or already purchased
  Future<bool> purchaseDecoration(String decorationId) async {
    try {
      final decorationCatalog = getDecorationCatalog();
      final decorationIndex = decorationCatalog.indexWhere((d) => d.id == decorationId);
      
      if (decorationIndex == -1) {
        throw ArgumentError('Decoration with id $decorationId not found');
      }

      final decoration = decorationCatalog[decorationIndex];
      
      // Check if already purchased
      if (decoration.isPurchased) {
        return false;
      }

      // Check if user can afford
      if (!canAfford(decoration.coinCost)) {
        return false;
      }

      // Deduct coins
      final deductSuccess = await _coinService.deductCoins(decoration.coinCost);
      if (!deductSuccess) {
        return false;
      }

      // Update decoration catalog
      final updatedDecoration = decoration.copyWith(
        isPurchased: true,
        purchasedAt: DateTime.now(),
      );
      decorationCatalog[decorationIndex] = updatedDecoration;
      await _repository.saveDecorationCatalog(decorationCatalog);

      // Update user inventory
      final inventory = _repository.getUserInventory() ?? _createDefaultInventory();
      final updatedInventory = inventory.copyWith(
        purchasedDecorationIds: [...inventory.purchasedDecorationIds, decorationId],
      );
      await _repository.saveUserInventory(updatedInventory);

      return true;
    } catch (e) {
      throw Exception('Failed to purchase decoration: $e');
    }
  }

  /// Check if user can afford an item with the given cost
  bool canAfford(int cost) {
    try {
      final currentBalance = _coinService.getCoinBalance();
      return currentBalance >= cost;
    } catch (e) {
      throw Exception('Failed to check affordability: $e');
    }
  }

  /// Initialize default fish catalog with 5 fish as specified in design
  List<Fish> _initializeDefaultFishCatalog() {
    return [
      Fish(
        id: 'fish_1',
        name: 'Goldfish',
        imagePath: 'assets/images/fish_goldfish.png',
        coinCost: 50,
        isPurchased: false,
      ),
      Fish(
        id: 'fish_2',
        name: 'Clownfish',
        imagePath: 'assets/images/fish_clownfish.png',
        coinCost: 75,
        isPurchased: false,
      ),
      Fish(
        id: 'fish_3',
        name: 'Blue Tang',
        imagePath: 'assets/images/fish_blue_tang.png',
        coinCost: 100,
        isPurchased: false,
      ),
      Fish(
        id: 'fish_4',
        name: 'Angelfish',
        imagePath: 'assets/images/fish_angelfish.png',
        coinCost: 125,
        isPurchased: false,
      ),
      Fish(
        id: 'fish_5',
        name: 'Seahorse',
        imagePath: 'assets/images/fish_seahorse.png',
        coinCost: 150,
        isPurchased: false,
      ),
    ];
  }

  /// Initialize default decoration catalog with 5 decorations as specified in design
  List<Decoration> _initializeDefaultDecorationCatalog() {
    return [
      Decoration(
        id: 'decoration_1',
        name: 'Seaweed',
        imagePath: 'assets/images/decoration_seaweed.png',
        coinCost: 25,
        isPurchased: false,
      ),
      Decoration(
        id: 'decoration_2',
        name: 'Coral',
        imagePath: 'assets/images/decoration_coral.png',
        coinCost: 30,
        isPurchased: false,
      ),
      Decoration(
        id: 'decoration_3',
        name: 'Starfish',
        imagePath: 'assets/images/decoration_starfish.png',
        coinCost: 40,
        isPurchased: false,
      ),
      Decoration(
        id: 'decoration_4',
        name: 'Treasure Chest',
        imagePath: 'assets/images/decoration_treasure_chest.png',
        coinCost: 50,
        isPurchased: false,
      ),
      Decoration(
        id: 'decoration_5',
        name: 'Castle',
        imagePath: 'assets/images/decoration_castle.png',
        coinCost: 75,
        isPurchased: false,
      ),
    ];
  }

  /// Create a default inventory if none exists
  UserInventory _createDefaultInventory() {
    return UserInventory(
      coinBalance: 0,
      purchasedFishIds: [],
      purchasedDecorationIds: [],
      activeFishIds: [],
      activeDecorationIds: [],
    );
  }
}
