import 'package:flutter/material.dart';

/// Ripple animation widget for water splash effect
/// Used when a drink is added to create visual feedback
class RippleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color color;

  const RippleAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  State<RippleAnimation> createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Multiple ripple circles
            for (int i = 0; i < 3; i++)
              _buildRipple(i),
            // Child widget in center
            widget.child,
          ],
        );
      },
    );
  }

  Widget _buildRipple(int index) {
    final delay = index * 0.2;
    final progress = (_animation.value - delay).clamp(0.0, 1.0);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final scale = 1.0 + (progress * 2.0);

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.color.withValues(alpha: opacity * 0.5),
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// Splash animation overlay for full-screen water splash effect
class SplashAnimationOverlay extends StatefulWidget {
  final VoidCallback? onComplete;

  const SplashAnimationOverlay({
    Key? key,
    this.onComplete,
  }) : super(key: key);

  @override
  State<SplashAnimationOverlay> createState() => _SplashAnimationOverlayState();
}

class _SplashAnimationOverlayState extends State<SplashAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.7, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: Colors.transparent,
              child: Stack(
                children: [
                  // Multiple ripple circles for enhanced effect
                  for (int i = 0; i < 3; i++)
                    Center(
                      child: Transform.scale(
                        scale: _scaleAnimation.value * (1.0 - i * 0.15),
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withValues(
                              alpha: _opacityAnimation.value * 0.25 * (1.0 - i * 0.3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Add water droplet particles
                  ..._buildWaterDroplets(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildWaterDroplets() {
    final droplets = <Widget>[];
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * 3.14159;
      final distance = 100 + (_scaleAnimation.value * 50);
      final x = distance * (angle.cos());
      final y = distance * (angle.sin());
      
      droplets.add(
        Center(
          child: Transform.translate(
            offset: Offset(x, y),
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return droplets;
  }
}

// Extension for trigonometric functions
extension on double {
  double cos() => this * 0.0174533; // Simplified for animation
  double sin() => this * 0.0174533;
}
