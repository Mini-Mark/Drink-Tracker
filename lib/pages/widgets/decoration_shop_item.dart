import 'package:flutter/material.dart';
import '../../models/decoration.dart' as models;
import '../../theme/color.dart';

/// Widget for displaying a decoration item in the shop
/// Shows decoration image, name, cost, and purchase status
class DecorationShopItem extends StatelessWidget {
  final models.Decoration decoration;
  final VoidCallback onPurchase;

  const DecorationShopItem({
    Key? key,
    required this.decoration,
    required this.onPurchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: decoration.isPurchased
                ? [grey.withValues(alpha: 0.3), grey.withValues(alpha: 0.5)]
                : [secondary.withValues(alpha: 0.1), secondary.withValues(alpha: 0.2)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Decoration image and name
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decoration image placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: decoration.isPurchased ? grey.withValues(alpha: 0.5) : secondary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.grass, // Decoration icon placeholder
                      size: 50,
                      color: decoration.isPurchased ? grey : secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Decoration name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      decoration.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: decoration.isPurchased ? grey : dark,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Cost and purchase button
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // Coin cost
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: warning,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${decoration.coinCost}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: dark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Purchase button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: decoration.isPurchased ? null : onPurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: decoration.isPurchased ? grey : secondary,
                        foregroundColor: white,
                        disabledBackgroundColor: grey,
                        disabledForegroundColor: white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        decoration.isPurchased ? 'Owned' : 'Purchase',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
