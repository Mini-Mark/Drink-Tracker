import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/app_state.dart';
import '../../models/fish.dart';
import '../../models/decoration.dart' as models;

/// AquariumWidget displays an interactive aquarium with animated fish and decorations
/// Fish appear progressively as the user drinks more water
/// Integrates with the wave animation to create a cohesive aquarium experience
class AquariumWidget extends StatefulWidget {
  const AquariumWidget({Key? key}) : super(key: key);

  @override
  State<AquariumWidget> createState() => _AquariumWidgetState();
}

class _AquariumWidgetState extends State<AquariumWidget>
    with TickerProviderStateMixin {
  final List<FishAnimationController> _fishControllers = [];
  final math.Random _random = math.Random();

  @override
  void dispose() {
    // Dispose all animation controllers
    for (var controller in _fishControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final size = MediaQuery.of(context).size;
        
        // Get aquarium data from AppState
        final currentML = appState.getTotalConsumptionForSelectedDate();
        final dailyRequirement = appState.userProfile?.dailyWaterRequirement ?? 2000;
        final inventory = appState.inventory;
        
        if (inventory == null) {
          return const SizedBox.shrink();
        }

        // Get active fish and decorations
        final activeFish = _getActiveFishFromInventory(appState);
        final activeDecorations = _getActiveDecorationsFromInventory(appState);
        
        // Calculate how many fish should be visible based on water consumption
        final visibleFishCount = _calculateVisibleFishCount(
          currentML,
          dailyRequirement,
          activeFish.length,
        );

        // Update fish controllers if needed
        _updateFishControllers(activeFish, visibleFishCount);

        return SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            children: [
              // Render decorations at the bottom
              ..._buildDecorations(activeDecorations, size),
              
              // Render animated fish
              ..._buildAnimatedFish(visibleFishCount, size),
            ],
          ),
        );
      },
    );
  }

  /// Get active fish from inventory
  List<Fish> _getActiveFishFromInventory(AppState appState) {
    try {
      final inventory = appState.inventory;
      if (inventory == null) return [];
      
      // Get all fish from catalog
      final allFish = appState.getFishCatalog();
      
      // Filter to only active fish (those in the aquarium)
      final activeFish = allFish.where((fish) {
        return inventory.activeFishIds.contains(fish.id);
      }).toList();
      
      return activeFish;
    } catch (e) {
      debugPrint('Error getting active fish: $e');
      return [];
    }
  }

  /// Get active decorations from inventory
  List<models.Decoration> _getActiveDecorationsFromInventory(AppState appState) {
    try {
      final inventory = appState.inventory;
      if (inventory == null) return [];
      
      // Get all decorations from catalog
      final allDecorations = appState.getDecorationCatalog();
      
      // Filter to only active decorations (those in the aquarium)
      final activeDecorations = allDecorations.where((decoration) {
        return inventory.activeDecorationIds.contains(decoration.id);
      }).toList();
      
      return activeDecorations;
    } catch (e) {
      debugPrint('Error getting active decorations: $e');
      return [];
    }
  }

  /// Calculate visible fish count based on water consumption
  int _calculateVisibleFishCount(int currentML, int targetML, int totalFish) {
    if (targetML <= 0 || totalFish == 0) return 0;
    if (currentML <= 0) return 0;

    // Calculate percentage and determine visible fish count
    final percentage = currentML / targetML;
    final visibleCount = (percentage * totalFish).floor();

    // Ensure at least 1 fish is visible if any water consumed
    return visibleCount.clamp(1, totalFish);
  }

  /// Update fish animation controllers
  void _updateFishControllers(List<Fish> activeFish, int visibleCount) {
    // Dispose old controllers if fish count changed
    if (_fishControllers.length != visibleCount) {
      for (var controller in _fishControllers) {
        controller.dispose();
      }
      _fishControllers.clear();

      // Create new controllers for visible fish
      for (int i = 0; i < visibleCount; i++) {
        _fishControllers.add(
          FishAnimationController(
            vsync: this,
            random: _random,
            fishIndex: i,
          ),
        );
      }
    }
  }

  /// Build decoration widgets
  List<Widget> _buildDecorations(List<models.Decoration> decorations, Size size) {
    final List<Widget> decorationWidgets = [];

    for (int i = 0; i < decorations.length; i++) {
      final decoration = decorations[i];
      
      // Position decorations at the bottom of the screen
      // Distribute them horizontally
      final xPosition = (size.width / (decorations.length + 1)) * (i + 1);
      final yPosition = size.height * 0.75; // Near bottom

      decorationWidgets.add(
        Positioned(
          left: xPosition - 25, // Center the decoration
          top: yPosition,
          child: _buildDecorationWidget(decoration),
        ),
      );
    }

    return decorationWidgets;
  }

  /// Build a single decoration widget
  Widget _buildDecorationWidget(models.Decoration decoration) {
    // Use a placeholder icon for decorations
    // In production, this would load the actual image from decoration.imagePath
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.brown.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getDecorationIcon(decoration.name),
        color: Colors.brown,
        size: 30,
      ),
    );
  }

  /// Get icon for decoration based on name
  IconData _getDecorationIcon(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('coral')) return Icons.grass;
    if (nameLower.contains('chest')) return Icons.inventory_2;
    if (nameLower.contains('castle')) return Icons.castle;
    if (nameLower.contains('seaweed')) return Icons.eco;
    if (nameLower.contains('star')) return Icons.star;
    return Icons.category;
  }

  /// Build animated fish widgets
  List<Widget> _buildAnimatedFish(int visibleCount, Size size) {
    final List<Widget> fishWidgets = [];

    for (int i = 0; i < visibleCount && i < _fishControllers.length; i++) {
      fishWidgets.add(
        AnimatedFishWidget(
          key: ValueKey('fish_$i'),
          controller: _fishControllers[i],
          screenSize: size,
          appearDelay: Duration(milliseconds: i * 400), // Stagger appearance with more delay
          fishIndex: i,
        ),
      );
    }

    return fishWidgets;
  }
}

/// Controller for individual fish animation
class FishAnimationController {
  final TickerProvider vsync;
  final math.Random random;
  final int fishIndex;

  late AnimationController _positionController;
  late Animation<Offset> _positionAnimation;

  FishAnimationController({
    required this.vsync,
    required this.random,
    required this.fishIndex,
  }) {
    _initializeAnimation();
  }

  void _initializeAnimation() {
    // Create animation controller with random duration for variety
    final duration = 8 + random.nextInt(7); // 8-14 seconds
    _positionController = AnimationController(
      duration: Duration(seconds: duration),
      vsync: vsync,
    );

    // Create random path for fish to swim
    _createNewPath();

    // Loop the animation
    _positionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _createNewPath();
        _positionController.forward(from: 0.0);
      }
    });

    _positionController.forward();
  }

  void _createNewPath() {
    // Create random start and end positions
    final startX = random.nextDouble();
    final startY = 0.3 + random.nextDouble() * 0.4; // Middle 40% of screen
    final endX = random.nextDouble();
    final endY = 0.3 + random.nextDouble() * 0.4;

    _positionAnimation = Tween<Offset>(
      begin: Offset(startX, startY),
      end: Offset(endX, endY),
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeInOut,
    ));
  }

  Animation<Offset> get positionAnimation => _positionAnimation;
  AnimationController get controller => _positionController;

  void dispose() {
    _positionController.dispose();
  }
}

/// Animated fish widget that swims across the screen
class AnimatedFishWidget extends StatefulWidget {
  final FishAnimationController controller;
  final Size screenSize;
  final Duration appearDelay;
  final int fishIndex;

  const AnimatedFishWidget({
    Key? key,
    required this.controller,
    required this.screenSize,
    this.appearDelay = Duration.zero,
    required this.fishIndex,
  }) : super(key: key);

  @override
  State<AnimatedFishWidget> createState() => _AnimatedFishWidgetState();
}

class _AnimatedFishWidgetState extends State<AnimatedFishWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _appearController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _appearController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _appearController,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _appearController,
        curve: Curves.easeIn,
      ),
    );

    // Start appearance animation after delay
    Future.delayed(widget.appearDelay, () {
      if (mounted) {
        _appearController.forward();
      }
    });
  }

  @override
  void dispose() {
    _appearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.controller.positionAnimation,
        _appearController,
      ]),
      builder: (context, child) {
        final position = widget.controller.positionAnimation.value;
        
        // Calculate actual screen position
        final left = position.dx * widget.screenSize.width;
        final top = position.dy * widget.screenSize.height;

        // Determine fish direction based on movement
        final previousPosition = widget.controller.positionAnimation.value;
        final isMovingRight = position.dx > previousPosition.dx;

        return Positioned(
          left: left - 20, // Center the fish
          top: top - 15,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateY(isMovingRight ? 0.0 : 3.14159), // Flip horizontally
                child: _buildFishIcon(),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build fish icon widget
  Widget _buildFishIcon() {
    // Use different fish emojis for variety
    final fishEmojis = ['🐟', '🐠', '🐡', '🦈', '🐙'];
    final fishEmoji = fishEmojis[widget.fishIndex % fishEmojis.length];
    
    // Add subtle floating animation
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 2),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final offset = math.sin(value * 2 * math.pi) * 3;
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      onEnd: () {
        // Restart the animation
        if (mounted) {
          setState(() {});
        }
      },
      child: Container(
        width: 40,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            fishEmoji,
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }
}
