import 'package:flutter/animation.dart';

class UtilsService {
  /// Convert hex color string to Color object
  Color hexToColor(String hex) {
    var colorString = hex.replaceFirst("#", "0xFF");
    return Color(int.parse(colorString));
  }
}
