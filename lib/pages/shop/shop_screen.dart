import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
    final iconList = <IconData>[
      Icons.home_rounded,
      Icons.bar_chart_sharp,
      Icons.history,
      Icons.settings,
      Icons.store,
    ];
    final labelList = ["Home", "Statistics", "History", "Settings", "Shop"];

    return Consumer<AppState>(
      builder: (context, appState, child) {
        final coinBalance = appState.getCoinBalance();
        _animateCoinChange(coinBalance);

        return Scaffold(
          backgroundColor: white,
          appBar: AppBar(
            backgroundColor: primary,
            elevation: 0,
            title: const Text(
              'Shop',
              style: TextStyle(
                color: white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(
                children: [
                  // Coin balance display with animation
                  AnimatedBuilder(
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
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                      alpha: 0.1 +
                                          (_coinAnimationController.value *
                                              0.1)),
                                  blurRadius:
                                      8 + (_coinAnimationController.value * 4),
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '$coinBalance Coins',
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
                      );
                    },
                  ),
                  // Tab bar
                  TabBar(
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
}
