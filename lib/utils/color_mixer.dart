import 'package:flutter/material.dart';
import '../models/drink_entry.dart';

/// Utility class for mixing colors based on drink consumption
class ColorMixer {
  /// Mix colors from multiple drinks based on their volumes
  /// Returns a blended color representing all drinks consumed
  static Color mixDrinkColors(List<DrinkEntry> entries, List<Map<String, dynamic>> drinksList) {
    if (entries.isEmpty) {
      // Default to blue water color if no drinks
      return const Color(0xFF2196F3);
    }

    // Calculate total volume
    int totalVolume = entries.fold(0, (sum, entry) => sum + entry.mlAmount);
    
    if (totalVolume == 0) {
      return const Color(0xFF2196F3);
    }

    // Accumulate weighted RGB values
    double totalRed = 0;
    double totalGreen = 0;
    double totalBlue = 0;

    for (var entry in entries) {
      // Find the drink color from drinksList
      final drink = drinksList.firstWhere(
        (d) => d['id'] == entry.drinkId,
        orElse: () => drinksList.isNotEmpty ? drinksList[0] : {'color': '#2196F3'}, // Default to water
      );

      // Parse hex color
      final colorHex = drink['color'] as String;
      final color = _hexToColor(colorHex);

      // Weight by volume proportion
      final weight = entry.mlAmount / totalVolume;
      
      totalRed += color.red * weight;
      totalGreen += color.green * weight;
      totalBlue += color.blue * weight;
    }

    // Create the mixed color
    return Color.fromARGB(
      255,
      totalRed.round().clamp(0, 255),
      totalGreen.round().clamp(0, 255),
      totalBlue.round().clamp(0, 255),
    );
  }

  /// Convert hex string to Color
  static Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
