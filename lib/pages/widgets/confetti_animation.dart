import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Confetti animation widget for celebration effects
/// Used when achievements are unlocked or goals are completed
class ConfettiAnimation extends StatefulWidget {
  final Duration duration;
  final int particleCount;

  const ConfettiAnimation({
    Key? key,
    this.duration = const Duration(seconds: 3),
    this.particleCount = 50,
  }) : super(key: key);

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Generate random particles
    _particles = List.generate(
      widget.particleCount,
      (index) => ConfettiParticle(
        color: _getRandomColor(),
        startX: _random.nextDouble(),
        startY: -0.1,
        endX: _random.nextDouble(),
        endY: 1.2,
        rotation: _random.nextDouble() * 2 * math.pi,
        size: 5 + _random.nextDouble() * 10,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class ConfettiParticle {
  final Color color;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double rotation;
  final double size;

  ConfettiParticle({
    required this.color,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.rotation,
    required this.size,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final x = particle.startX + (particle.endX - particle.startX) * progress;
      final y = particle.startY + (particle.endY - particle.startY) * progress;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1.0 - progress)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(particle.rotation * progress * 4);

      // Draw confetti piece (rectangle)
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size * 0.6,
      );
      canvas.drawRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Celebration overlay with confetti and sparkles
class CelebrationOverlay extends StatelessWidget {
  const CelebrationOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: const [
            ConfettiAnimation(
              duration: Duration(seconds: 3),
              particleCount: 50,
            ),
          ],
        ),
      ),
    );
  }
}
