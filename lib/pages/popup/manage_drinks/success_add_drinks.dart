import 'package:auto_size_text/auto_size_text.dart';
import 'package:drinktracker/services/popup_service.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../widgets/confetti_animation.dart';
import '../../widgets/achievement_unlock_dialog.dart';

class Popup_SuccessAddDrinks extends StatefulWidget {
  final int drinksID;
  final int ml;
  const Popup_SuccessAddDrinks(
      {super.key, required this.drinksID, required this.ml});

  @override
  State<Popup_SuccessAddDrinks> createState() => _Popup_SuccessAddDrinksState();
}

class _Popup_SuccessAddDrinksState extends State<Popup_SuccessAddDrinks> {
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _addDrinkEntry();
  }

  Future<void> _addDrinkEntry() async {
    if (_isAdding) return;

    setState(() {
      _isAdding = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final result = await appState.addDrinkEntry(widget.drinksID, widget.ml);

      if (mounted) {
        // Show goal completion celebration if goal was just completed
        if (result['goalCompleted'] == true) {
          _showGoalCompletionCelebration();
        }

        // Check for newly completed achievements
        final newlyCompleted = result['newlyCompletedAchievements'];
        if (newlyCompleted != null && newlyCompleted.isNotEmpty) {
          // Wait a bit before showing achievement notification
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            _showAchievementUnlockedNotification(newlyCompleted);
          }
        }
      }
    } catch (e) {
      // Error adding drink entry - show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add drink entry: ${e.toString()}'),
            backgroundColor: danger,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  void _showGoalCompletionCelebration() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Confetti animation overlay
            const CelebrationOverlay(),
            // Dialog content
            Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated celebration icon with rotation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Transform.rotate(
                            angle: value * 0.5 - 0.25,
                            child: child,
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.emoji_events,
                        color: Color.fromARGB(255, 255, 170, 0), // Gold color
                        size: 80,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '🎉 Congratulations! 🎉',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Daily goal completed!',
                      style: TextStyle(
                        fontSize: 18,
                        color: dark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    // Animated coin reward
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.bounceOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.monetization_on,
                                color: Color.fromARGB(255, 255, 170, 0),
                                size: 24),
                            SizedBox(width: 8),
                            Text(
                              '+10 coins earned!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Awesome!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAchievementUnlockedNotification(List<dynamic> achievements) async {
    // Show achievements one at a time to avoid stacking dialogs
    for (var achievement in achievements) {
      if (!mounted) return;

      await showAchievementUnlockDialog(
        context,
        achievement,
      );

      // Small delay between showing multiple achievements
      if (achievements.indexOf(achievement) < achievements.length - 1) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final appState = Provider.of<AppState>(context, listen: false);
    dynamic drinksData = appState.getDrinksByID(widget.drinksID);

    return Column(
      children: [
        PopupService().getHeader(context: context),
        SizedBox(
          width: size.width,
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated success icon
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
                  child: Stack(alignment: Alignment.topRight, children: [
                    Icon(drinksData["icon"],
                        color: drinksData["color"] == null
                            ? dark
                            : drinksData["color"],
                        size: size.width * 0.25),
                    const Icon(Icons.circle, color: white, size: 30),
                    const Icon(Icons.check_circle_rounded,
                        color: success, size: 30),
                  ]),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  child: AutoSizeText.rich(
                    TextSpan(
                        text: "Added ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: title_lg - 4,
                          color: drinksData["color"] == null
                              ? dark
                              : drinksData["color"],
                        ),
                        children: [
                          TextSpan(
                            text: "${drinksData['name']} ${widget.ml}ml",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: title_lg - 4,
                                color: dark),
                          )
                        ]),
                    style: const TextStyle(color: light_secondary),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 30,
        )
      ],
    );
  }
}
