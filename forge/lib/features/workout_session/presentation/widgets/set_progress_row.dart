import 'package:flutter/material.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_state.dart';
import 'package:forge/features/workout_session/presentation/widgets/set_progress_dot.dart';

const double _kDotSpacing = 6.0;

class SetProgressRow extends StatelessWidget {
  const SetProgressRow({
    required this.statuses,
    required this.currentSetIndex,
    super.key,
  });

  final List<SetStatus> statuses;
  final int currentSetIndex;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: _kDotSpacing,
      runSpacing: _kDotSpacing,
      children: List.generate(statuses.length, (index) {
        return SetProgressDot(
          status: statuses[index],
          isCurrent: index == currentSetIndex,
        );
      }),
    );
  }
}
