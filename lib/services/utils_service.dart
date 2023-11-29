import 'package:flutter/animation.dart';

class UtilsService {
  HexToColor(String hex) {
    var colorString = hex.replaceFirst("#", "0xFF");
    return Color(int.parse(colorString));
  }
}
