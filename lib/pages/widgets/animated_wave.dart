import 'package:drinktracker/theme/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class AnimatedWaveAnimation extends StatefulWidget {
  final double heightPercent;
  final dynamic callback;

  AnimatedWaveAnimation({required this.heightPercent, required this.callback});

  @override
  State<AnimatedWaveAnimation> createState() => _AnimatedWaveAnimationState();
}

class _AnimatedWaveAnimationState extends State<AnimatedWaveAnimation>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  double heightAnimation = 0.0;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation =
        Tween<double>(begin: 0, end: widget.heightPercent).animate(controller)
          ..addListener(() async {
            Function callbackFunc = await widget.callback;
            callbackFunc(1);

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

            print("Animation: ${animation.value}");
          });
    controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedWaveAnimation oldWidget) {
    print("NEW: ${widget.heightPercent}");
    print("OLD: ${oldWidget.heightPercent}");
    print("heightAnimation: ${heightAnimation}");

    if (widget.heightPercent != heightAnimation) {
      controller.animateTo(widget.heightPercent);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WaveWidget(
      config: CustomConfig(
        colors: [primary.withAlpha(80), primary.withAlpha(50)],
        durations: [25000, 19440],
        heightPercentages: [
          1 - 0.12 - (heightAnimation * 0.01),
          1 - 0.12 - ((heightAnimation * 0.01 + 0.01)),
        ],
      ),
      waveAmplitude: 25.0,
      size: Size(double.infinity, double.infinity),
    );
  }
}
