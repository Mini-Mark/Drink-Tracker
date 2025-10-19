import 'package:flutter/material.dart';
import '../../models/fish.dart';
import '../../theme/color.dart';

/// Widget for displaying a fish item in the shop
/// Shows fish image, name, cost, and purchase status
class FishShopItem extends StatelessWidget {
  final Fish fish;
  final VoidCallback onPurchase;

  const FishShopItem({
    Key? key,
    required this.fish,
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
            colors: fish.isPurchased
                ? [grey.withValues(alpha: 0.3), grey.withValues(alpha: 0.5)]
                : [primary.withValues(alpha: 0.1), primary.withValues(alpha: 0.2)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Fish image and name
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Fish image placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: fish.isPurchased ? grey.withValues(alpha: 0.5) : primary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.set_meal, // Fish icon placeholder
                      size: 50,
                      color: fish.isPurchased ? grey : primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Fish name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      fish.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: fish.isPurchased ? grey : dark,
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
                        '${fish.coinCost}',
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
                      onPressed: fish.isPurchased ? null : onPurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: fish.isPurchased ? grey : primary,
                        foregroundColor: white,
                        disabledBackgroundColor: grey,
                        disabledForegroundColor: white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        fish.isPurchased ? 'Owned' : 'Purchase',
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
