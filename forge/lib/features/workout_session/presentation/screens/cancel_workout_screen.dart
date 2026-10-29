import 'package:forge/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:forge/features/workout_session/presentation/widgets/cancel_workout_dialog.dart';
import 'package:go_router/go_router.dart';

class CancelWorkoutScreen extends StatelessWidget {
  static const String routePath = '/workout/cancel';
  static const String routeName = 'cancelWorkout';

  const CancelWorkoutScreen({required this.planName, super.key});

  static const double _horizontalPadding = 30;

  final String planName;

  void _handleKeepGoing(BuildContext context) => context.pop();

  void _handleDiscard(BuildContext context) => context.go(HomeScreen.routePath);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleKeepGoing(context);
      },
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _handleKeepGoing(context),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CancelWorkoutScreen._horizontalPadding,
                ),
                // Absorbs taps so only the scrim outside the card dismisses.
                child: GestureDetector(
                  onTap: () {},
                  child: CancelWorkoutDialog(
                    planName: planName,
                    onKeepGoing: () => _handleKeepGoing(context),
                    onDiscard: () => _handleDiscard(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
