import 'package:flutter/animation.dart';

class UtilsService {
  /// Convert hex color string to Color object
  Color hexToColor(String hex) {
    var colorString = hex.replaceFirst("#", "0xFF");
    return Color(int.parse(colorString));
  }

  /// Convert Color object to hex string
  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
