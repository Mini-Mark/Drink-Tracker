import 'package:flutter/material.dart';
import '../../models/achievement.dart';
import '../../theme/color.dart';
import '../../theme/font_size.dart';
import 'confetti_animation.dart';

/// Dialog that displays when an achievement is unlocked
/// Shows celebration animation and coin reward
class AchievementUnlockDialog extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;

  const AchievementUnlockDialog({
    Key? key,
    required this.achievement,
    this.onDismiss,
  }) : super(key: key);

  @override
  State<AchievementUnlockDialog> createState() =>
      _AchievementUnlockDialogState();
}

class _AchievementUnlockDialogState extends State<AchievementUnlockDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
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
    return Stack(
      children: [
        // Confetti animation overlay
        const Positioned.fill(
          child: IgnorePointer(
            child: ConfettiAnimation(
              duration: Duration(seconds: 3),
              particleCount: 60,
            ),
          ),
        ),

        // Dialog content
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
                    color: white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // Close button at top right
                      Positioned(
                        top: -15,
                        right: -15,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onDismiss?.call();
                          },
                          color: dark.withValues(alpha: 0.6),
                          iconSize: 24,
                        ),
                      ),

                      // Main content
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Trophy icon on the left
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              size: 50,
                              color: Colors.orange,
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Details on the right
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Achievement name
                                Text(
                                  widget.achievement.name,
                                  style: const TextStyle(
                                    fontSize: title_md,
                                    fontWeight: FontWeight.w600,
                                    color: dark,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Achievement description
                                Text(
                                  widget.achievement.description,
                                  style: TextStyle(
                                    fontSize: text_md,
                                    color: dark.withValues(alpha: 0.7),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Coin reward display
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: Colors.orange,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.monetization_on,
                                        color: Colors.orange,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '+${widget.achievement.coinReward}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: dark,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'coins',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: dark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

/// Show achievement unlock dialog
/// Returns a Future that completes when the dialog is dismissed
Future<void> showAchievementUnlockDialog(
  BuildContext context,
  Achievement achievement, {
  VoidCallback? onDismiss,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AchievementUnlockDialog(
      achievement: achievement,
      onDismiss: onDismiss,
    ),
  );
}
