import 'package:drinktracker/theme/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class AnimatedWaveAnimation extends StatefulWidget {
  final double heightPercent;
  final dynamic callback;
  final Color? color;

  const AnimatedWaveAnimation({
    Key? key,
    required this.heightPercent,
    required this.callback,
    this.color,
  }) : super(key: key);

  @override
  State<AnimatedWaveAnimation> createState() => _AnimatedWaveAnimationState();
}

class _AnimatedWaveAnimationState extends State<AnimatedWaveAnimation>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  late AnimationController pulseController;
  late Animation<double> pulseAnimation;

  double heightAnimation = 0.0;
  bool isPulsing = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    animation = Tween<double>(begin: 0, end: widget.heightPercent).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    )..addListener(() {
        // Call callback if provided - simplified to avoid parameter mismatch
        if (widget.callback != null) {
          try {
            widget.callback();
          } catch (e) {
            // Ignore callback errors
          }
        }

        if (widget.heightPercent != heightAnimation) {
          if (widget.heightPercent < heightAnimation) {
            setState(() {
              heightAnimation -= 1;
              if (widget.heightPercent > heightAnimation) {
                heightAnimation = widget.heightPercent;
              }
            });
          } else {
            setState(() {
              heightAnimation += 1;
              if (widget.heightPercent < heightAnimation) {
                heightAnimation = widget.heightPercent;
              }
            });
          }
        } else {
          controller.stop();
        }
      });

    // Pulse animation for when drinks are added
    pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeOut),
    );

    controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedWaveAnimation oldWidget) {
    if (widget.heightPercent != heightAnimation) {
      controller.animateTo(widget.heightPercent);

      // Trigger pulse animation when height increases
      if (widget.heightPercent > oldWidget.heightPercent) {
        _triggerPulse();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  void _triggerPulse() {
    if (!isPulsing) {
      setState(() {
        isPulsing = true;
      });
      pulseController.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() {
            isPulsing = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        // Add pulse effect to wave amplitude when drink is added
        final amplitudeBoost = isPulsing ? pulseAnimation.value * 15.0 : 0.0;
        final waveAmplitude = 25.0 + amplitudeBoost;

        // Add slight color intensity boost during pulse
        final colorBoost = isPulsing ? (pulseAnimation.value * 30).toInt() : 0;
        final waveColor = widget.color ?? primary;

        return WaveWidget(
          config: CustomConfig(
            colors: [
              waveColor.withAlpha(80 + colorBoost),
              waveColor.withAlpha(50 + colorBoost),
            ],
            durations: [25000, 19440],
            heightPercentages: [
              1 - 0.12 - (heightAnimation * 0.01),
              1 - 0.12 - ((heightAnimation * 0.01 + 0.01)),
            ],
          ),
          waveAmplitude: waveAmplitude,
          size: const Size(double.infinity, double.infinity),
        );
      },
    );
  }
}
