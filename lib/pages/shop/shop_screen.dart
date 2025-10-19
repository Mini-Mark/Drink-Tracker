import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../models/fish.dart';
import '../../models/decoration.dart' as models;
import '../../theme/color.dart';
import '../widgets/fish_shop_item.dart';
import '../widgets/decoration_shop_item.dart';
import '../widgets/achievement_unlock_dialog.dart';
import '../widgets/purchase_success_animation.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _coinAnimationController;
  late Animation<double> _coinShakeAnimation;
  int _previousCoinBalance = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _coinAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create shake animation for coin deduction
    _coinShakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _coinAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _coinAnimationController.dispose();
    super.dispose();
  }

  void _animateCoinChange(int newBalance) {
    if (_previousCoinBalance != newBalance && _previousCoinBalance > 0) {
      _coinAnimationController.forward(from: 0.0);
    }
    _previousCoinBalance = newBalance;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final coinBalance = appState.getCoinBalance();
        _animateCoinChange(coinBalance);

        return Scaffold(
          backgroundColor: white,
          appBar: AppBar(
            backgroundColor: primary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.backpack_outlined,
                color: white,
                size: 28,
              ),
              onPressed: () => _showInventoryDialog(appState),
              tooltip: 'My Items',
            ),
            title: const Text(
              'Shop',
              style: TextStyle(
                color: white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              // Coin balance display with animation
              Center(
                child: AnimatedBuilder(
                  animation: _coinAnimationController,
                  builder: (context, child) {
                    final scale =
                        1.0 + (_coinAnimationController.value * 0.15);
                    final shake = _coinShakeAnimation.value;
                    return Transform.translate(
                      offset: Offset(shake, 0),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                    alpha: 0.1 +
                                        (_coinAnimationController.value *
                                            0.1)),
                                blurRadius:
                                    6 + (_coinAnimationController.value * 3),
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 300),
                                tween: Tween(begin: 1.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Transform.rotate(
                                    angle:
                                        _coinAnimationController.value * 0.2,
                                    child: child,
                                  );
                                },
                                child: const Icon(
                                  Icons.monetization_on,
                                  color: warning,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$coinBalance',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: dark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: TabBar(
                controller: _tabController,
                indicatorColor: white,
                indicatorWeight: 3,
                labelColor: white,
                unselectedLabelColor: white.withValues(alpha: 0.6),
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: 'Fish'),
                  Tab(text: 'Decorations'),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildFishTab(appState),
              _buildDecorationTab(appState),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFishTab(AppState appState) {
    return FutureBuilder<List<Fish>>(
      future: _getFishCatalog(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: primary),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error loading fish catalog',
              style: TextStyle(color: danger),
            ),
          );
        }

        final fishList = snapshot.data ?? [];

        if (fishList.isEmpty) {
          return const Center(
            child: Text(
              'No fish available',
              style: TextStyle(color: grey, fontSize: 16),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: fishList.length,
          itemBuilder: (context, index) {
            return FishShopItem(
              fish: fishList[index],
              onPurchase: () =>
                  _handlePurchase(appState, fishList[index].id, 'fish'),
            );
          },
        );
      },
    );
  }

  Widget _buildDecorationTab(AppState appState) {
    return FutureBuilder<List<models.Decoration>>(
      future: _getDecorationCatalog(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: primary),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error loading decoration catalog',
              style: TextStyle(color: danger),
            ),
          );
        }

        final decorationList = snapshot.data ?? [];

        if (decorationList.isEmpty) {
          return const Center(
            child: Text(
              'No decorations available',
              style: TextStyle(color: grey, fontSize: 16),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: decorationList.length,
          itemBuilder: (context, index) {
            return DecorationShopItem(
              decoration: decorationList[index],
              onPurchase: () => _handlePurchase(
                  appState, decorationList[index].id, 'decoration'),
            );
          },
        );
      },
    );
  }

  Future<List<Fish>> _getFishCatalog() async {
    final appState = Provider.of<AppState>(context, listen: false);
    return appState.getFishCatalog();
  }

  Future<List<models.Decoration>> _getDecorationCatalog() async {
    final appState = Provider.of<AppState>(context, listen: false);
    return appState.getDecorationCatalog();
  }

  void _handlePurchase(
      AppState appState, String itemId, String itemType) async {
    // Get item details
    String itemName = '';
    int itemCost = 0;

    if (itemType == 'fish') {
      final fish = appState.getFishCatalog().firstWhere((f) => f.id == itemId);
      itemName = fish.name;
      itemCost = fish.coinCost;
    } else {
      final decoration =
          appState.getDecorationCatalog().firstWhere((d) => d.id == itemId);
      itemName = decoration.name;
      itemCost = decoration.coinCost;
    }

    // Check if user can afford
    final currentBalance = appState.getCoinBalance();
    if (currentBalance < itemCost) {
      _showInsufficientCoinsDialog(itemName, itemCost, currentBalance);
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showPurchaseConfirmationDialog(itemName, itemCost);
    if (confirmed != true) {
      return;
    }

    // Show loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            color: primary,
          ),
        );
      },
    );

    try {
      // Attempt purchase
      final result = await appState.purchaseItem(itemId, itemType);
      final success = result['success'] as bool;
      final newlyCompletedAchievements =
          result['newlyCompletedAchievements'] as List;

      // Dismiss loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;

      if (success) {
        // Show purchase success animation with coin deduction and item added effects
        if (mounted) {
          await showPurchaseSuccessAnimation(
            context,
            itemName: itemName,
            coinCost: itemCost,
            isFish: itemType == 'fish',
          );

          if (!mounted) return;

          // Show achievement unlock dialogs if any achievements were completed
          if (newlyCompletedAchievements.isNotEmpty) {
            // Wait a bit before showing achievement notifications
            await Future.delayed(const Duration(milliseconds: 300));
            if (!mounted) return;

            for (var achievement in newlyCompletedAchievements) {
              await showAchievementUnlockDialog(context, achievement);
              if (!mounted) return;

              // Small delay between multiple achievements
              if (newlyCompletedAchievements.indexOf(achievement) <
                  newlyCompletedAchievements.length - 1) {
                await Future.delayed(const Duration(milliseconds: 300));
                if (!mounted) return;
              }
            }
          }

          // Refresh the UI to show updated purchase status
          setState(() {});
        }
      } else {
        _showPurchaseErrorDialog(itemName);
      }
    } catch (e) {
      // Dismiss loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<bool?> _showPurchaseConfirmationDialog(String itemName, int cost) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirm Purchase',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: dark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Do you want to purchase $itemName?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              // Animated coin cost display
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (value * 0.2),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: warning, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: warning,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$cost Coins',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: dark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Purchase'),
            ),
          ],
        );
      },
    );
  }

  void _showInsufficientCoinsDialog(
      String itemName, int cost, int currentBalance) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.error_outline,
                color: danger,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                'Insufficient Coins',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You don\'t have enough coins to purchase $itemName.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Required:',
                    style: TextStyle(fontSize: 14, color: grey),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: warning,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$cost',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your balance:',
                    style: TextStyle(fontSize: 14, color: grey),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: warning,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$currentBalance',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: danger,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Earn more coins by completing achievements and meeting your daily water goals!',
                style: TextStyle(
                  fontSize: 14,
                  color: grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPurchaseErrorDialog(String itemName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.error_outline,
                color: danger,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                'Purchase Failed',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
            ],
          ),
          content: Text(
            'Failed to purchase $itemName. Please try again.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: danger,
                foregroundColor: white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showInventoryDialog(AppState appState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.backpack,
                        color: white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'My Items',
                        style: TextStyle(
                          color: white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: FutureBuilder(
                    future: _getInventoryData(appState),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(color: primary),
                          ),
                        );
                      }

                      final data = snapshot.data;
                      final ownedFish = (data?['fish'] as List<Fish>?) ?? [];
                      final ownedDecorations =
                          (data?['decorations'] as List<models.Decoration>?) ??
                              [];

                      if (ownedFish.isEmpty && ownedDecorations.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No items yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Purchase fish and decorations\nto fill your inventory!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (ownedFish.isNotEmpty) ...[
                              const Text(
                                'Fish',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: dark,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: ownedFish.map((fish) {
                                  return Container(
                                    width: 100,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: primary.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: primary.withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.set_meal,
                                            size: 30,
                                            color: primary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          fish.name,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: dark,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 24),
                            ],
                            if (ownedDecorations.isNotEmpty) ...[
                              const Text(
                                'Decorations',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: dark,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: ownedDecorations.map((decoration) {
                                  return Container(
                                    width: 100,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: success.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: success.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: success.withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.grass,
                                            size: 30,
                                            color: success,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          decoration.name,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: dark,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getInventoryData(AppState appState) async {
    final inventory = appState.inventory;
    if (inventory == null) {
      return {
        'fish': <Fish>[],
        'decorations': <models.Decoration>[],
      };
    }

    final allFish = appState.getFishCatalog();
    final allDecorations = appState.getDecorationCatalog();

    final ownedFish = allFish
        .where((fish) => inventory.purchasedFishIds.contains(fish.id))
        .toList();
    final ownedDecorations = allDecorations
        .where((decoration) =>
            inventory.purchasedDecorationIds.contains(decoration.id))
        .toList();

    return {
      'fish': ownedFish,
      'decorations': ownedDecorations,
    };
  }
}
