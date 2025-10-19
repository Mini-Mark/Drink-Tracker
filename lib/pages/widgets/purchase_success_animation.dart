import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/color.dart';

/// Purchase success animation widget
/// Shows coin deduction animation and item added to inventory effect
class PurchaseSuccessAnimation extends StatefulWidget {
  final String itemName;
  final int coinCost;
  final bool isFish;
  final VoidCallback? onComplete;

  const PurchaseSuccessAnimation({
    Key? key,
    required this.itemName,
    required this.coinCost,
    this.isFish = true,
    this.onComplete,
  }) : super(key: key);

  @override
  State<PurchaseSuccessAnimation> createState() =>
      _PurchaseSuccessAnimationState();
}

class _PurchaseSuccessAnimationState extends State<PurchaseSuccessAnimation>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _coinController;
  late AnimationController _itemController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _coinSlideAnimation;
  late Animation<double> _coinFadeAnimation;
  late Animation<Offset> _itemSlideAnimation;
  late Animation<double> _itemScaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Main dialog animation
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeIn,
    );

    // Coin deduction animation
    _coinController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _coinSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2),
    ).animate(CurvedAnimation(
      parent: _coinController,
      curve: Curves.easeInOut,
    ));

    _coinFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _coinController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    // Item added animation
    _itemController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _itemSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _itemController,
      curve: Curves.bounceOut,
    ));

    _itemScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _itemController,
      curve: Curves.elasticOut,
    ));

    // Pulse animation for the icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _pulseController.forward();
      }
    });

    // Start animations in sequence
    _startAnimations();
  }

  void _startAnimations() async {
    await _mainController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _coinController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    await _itemController.forward();
    // Start pulse animation after item appears
    _pulseController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _coinController.dispose();
    _itemController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sparkle particles
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _itemController,
              builder: (context, child) {
                return CustomPaint(
                  painter: SparklePainter(
                    progress: _itemController.value,
                  ),
                );
              },
            ),
          ),
        ),

        // Main dialog
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        success.withValues(alpha: 0.1),
                        white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success icon
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 500),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: success.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            size: 50,
                            color: success,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Purchase Successful!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: success,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'You purchased ${widget.itemName}!',
                        style: const TextStyle(
                          fontSize: 16,
                          color: dark,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Coin deduction animation
                      SizedBox(
                        height: 60,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SlideTransition(
                              position: _coinSlideAnimation,
                              child: FadeTransition(
                                opacity: _coinFadeAnimation,
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
                                      '-${widget.coinCost}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: danger,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Item added to inventory animation
                      SlideTransition(
                        position: _itemSlideAnimation,
                        child: ScaleTransition(
                          scale: _itemScaleAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: success,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Animated icon with pulse effect
                                AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _pulseAnimation.value,
                                      child: child,
                                    );
                                  },
                                  child: Icon(
                                    widget.isFish
                                        ? Icons.set_meal
                                        : Icons.grass,
                                    color: success,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Added to Aquarium!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: success,
                                      ),
                                    ),
                                    Text(
                                      'Visit Home to see it swim!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: success.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Close button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onComplete?.call();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: success,
                            foregroundColor: white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Great!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Painter for sparkle particles around the dialog
class SparklePainter extends CustomPainter {
  final double progress;
  final math.Random _random =
      math.Random(42); // Fixed seed for consistent positions

  SparklePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Generate sparkles around the center
    for (int i = 0; i < 20; i++) {
      final angle = (i / 20) * 2 * math.pi;
      final distance = 150 + (_random.nextDouble() * 50);
      final x = size.width / 2 + distance * math.cos(angle) * progress;
      final y = size.height / 2 + distance * math.sin(angle) * progress;

      final sparkleSize = 3 + _random.nextDouble() * 4;
      final opacity = (1.0 - progress) * (0.5 + _random.nextDouble() * 0.5);

      paint.color = warning.withValues(alpha: opacity);

      // Draw star-shaped sparkle
      _drawStar(canvas, Offset(x, y), sparkleSize, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final x = center.dx + size * math.cos(angle);
      final y = center.dy + size * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Inner point
      final innerAngle = angle + math.pi / 5;
      final innerX = center.dx + (size * 0.4) * math.cos(innerAngle);
      final innerY = center.dy + (size * 0.4) * math.sin(innerAngle);
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Show purchase success animation dialog
Future<void> showPurchaseSuccessAnimation(
  BuildContext context, {
  required String itemName,
  required int coinCost,
  bool isFish = true,
  VoidCallback? onComplete,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PurchaseSuccessAnimation(
      itemName: itemName,
      coinCost: coinCost,
      isFish: isFish,
      onComplete: onComplete,
    ),
  );
}
