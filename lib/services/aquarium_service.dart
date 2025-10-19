import '../models/fish.dart';
import '../models/decoration.dart';
import '../repositories/local_storage_repository.dart';

class AquariumService {
  final LocalStorageRepository _repository;

  AquariumService(this._repository);

  /// Calculate the number of fish that should be visible based on water consumption
  /// Formula: visibleFish = floor((currentML / targetML) * totalPurchasedFish)
  /// Minimum 1 fish visible if any water consumed and fish are owned
  /// All fish visible when goal reached
  int calculateVisibleFishCount(int currentML, int targetML) {
    if (targetML <= 0) return 0;
    if (currentML <= 0) return 0;

    final inventory = _repository.getUserInventory();
    if (inventory == null || inventory.activeFishIds.isEmpty) return 0;

    final totalActiveFish = inventory.activeFishIds.length;
    
    // Calculate percentage and determine visible fish count
    final percentage = currentML / targetML;
    final visibleCount = (percentage * totalActiveFish).floor();
    
    // Ensure at least 1 fish is visible if any water consumed
    return visibleCount.clamp(1, totalActiveFish);
  }

  /// Get list of active fish (fish currently displayed in aquarium)
  List<Fish> getActiveFish() {
    try {
      final inventory = _repository.getUserInventory();
      if (inventory == null) return [];

      final fishCatalog = _repository.getFishCatalog();
      
      // Filter fish catalog to only include active fish
      return fishCatalog
          .where((fish) => inventory.activeFishIds.contains(fish.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active fish: $e');
    }
  }

  /// Get list of active decorations (decorations currently displayed in aquarium)
  List<Decoration> getActiveDecorations() {
    try {
      final inventory = _repository.getUserInventory();
      if (inventory == null) return [];

      final decorationCatalog = _repository.getDecorationCatalog();
      
      // Filter decoration catalog to only include active decorations
      return decorationCatalog
          .where((decoration) => inventory.activeDecorationIds.contains(decoration.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active decorations: $e');
    }
  }

  /// Add a fish to the aquarium display
  Future<void> addFishToAquarium(String fishId) async {
    try {
      final inventory = _repository.getUserInventory();
      if (inventory == null) {
        throw Exception('User inventory not found');
      }

      // Check if fish is purchased
      if (!inventory.purchasedFishIds.contains(fishId)) {
        throw Exception('Fish must be purchased before adding to aquarium');
      }

      // Check if fish is already active
      if (inventory.activeFishIds.contains(fishId)) {
        return; // Already in aquarium, no action needed
      }

      // Add fish to active list
      final updatedActiveFishIds = List<String>.from(inventory.activeFishIds)
        ..add(fishId);

      final updatedInventory = inventory.copyWith(
        activeFishIds: updatedActiveFishIds,
      );

      await _repository.saveUserInventory(updatedInventory);
    } catch (e) {
      throw Exception('Failed to add fish to aquarium: $e');
    }
  }

  /// Remove a fish from the aquarium display
  Future<void> removeFishFromAquarium(String fishId) async {
    try {
      final inventory = _repository.getUserInventory();
      if (inventory == null) {
        throw Exception('User inventory not found');
      }

      // Check if fish is in aquarium
      if (!inventory.activeFishIds.contains(fishId)) {
        return; // Not in aquarium, no action needed
      }

      // Remove fish from active list
      final updatedActiveFishIds = List<String>.from(inventory.activeFishIds)
        ..remove(fishId);

      final updatedInventory = inventory.copyWith(
        activeFishIds: updatedActiveFishIds,
      );

      await _repository.saveUserInventory(updatedInventory);
    } catch (e) {
      throw Exception('Failed to remove fish from aquarium: $e');
    }
  }

  /// Add a decoration to the aquarium display
  Future<void> addDecorationToAquarium(String decorationId) async {
    try {
      final inventory = _repository.getUserInventory();
      if (inventory == null) {
        throw Exception('User inventory not found');
      }

      // Check if decoration is purchased
      if (!inventory.purchasedDecorationIds.contains(decorationId)) {
        throw Exception('Decoration must be purchased before adding to aquarium');
      }

      // Check if decoration is already active
      if (inventory.activeDecorationIds.contains(decorationId)) {
        return; // Already in aquarium, no action needed
      }

      // Add decoration to active list
      final updatedActiveDecorationIds = List<String>.from(inventory.activeDecorationIds)
        ..add(decorationId);

      final updatedInventory = inventory.copyWith(
        activeDecorationIds: updatedActiveDecorationIds,
      );

      await _repository.saveUserInventory(updatedInventory);
    } catch (e) {
      throw Exception('Failed to add decoration to aquarium: $e');
    }
  }

  /// Remove a decoration from the aquarium display
  Future<void> removeDecorationFromAquarium(String decorationId) async {
    try {
      final inventory = _repository.getUserInventory();
      if (inventory == null) {
        throw Exception('User inventory not found');
      }

      // Check if decoration is in aquarium
      if (!inventory.activeDecorationIds.contains(decorationId)) {
        return; // Not in aquarium, no action needed
      }

      // Remove decoration from active list
      final updatedActiveDecorationIds = List<String>.from(inventory.activeDecorationIds)
        ..remove(decorationId);

      final updatedInventory = inventory.copyWith(
        activeDecorationIds: updatedActiveDecorationIds,
      );

      await _repository.saveUserInventory(updatedInventory);
    } catch (e) {
      throw Exception('Failed to remove decoration from aquarium: $e');
    }
  }
}
