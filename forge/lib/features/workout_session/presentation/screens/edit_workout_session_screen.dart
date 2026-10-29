import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/navigation/workout_data_refresher.dart';
import 'package:forge/features/workout_session/application/bloc/edit_workout_session_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/edit_workout_session_event.dart';
import 'package:forge/features/workout_session/application/bloc/edit_workout_session_state.dart';
import 'package:forge/features/workout_session/presentation/screens/workout_history_detail_screen.dart';
import 'package:forge/features/workout_session/presentation/widgets/detail_skeleton.dart';
import 'package:forge/features/workout_session/presentation/widgets/edit_workout_session_form_view.dart';
import 'package:forge/core/widgets/error_card.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

/// Lets the user correct the sets of a logged workout.
class EditWorkoutSessionScreen extends StatelessWidget {
  static const String routeSegment = 'edit';
  static const String routePath =
      '${WorkoutHistoryDetailScreen.routePath}/$routeSegment';
  static const String routeName = 'historyEdit';

  const EditWorkoutSessionScreen({required this.sessionId, super.key});

  final String sessionId;

  void _onStateChanged(BuildContext context, EditWorkoutSessionState state) {
    if (state is! EditWorkoutSessionSaved) return;
    getIt<WorkoutDataRefresher>().refresh();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          context.l10n.editSessionTitle,
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: BlocConsumer<EditWorkoutSessionBloc, EditWorkoutSessionState>(
        listener: _onStateChanged,
        builder: (context, state) => switch (state) {
          EditWorkoutSessionLoading() ||
          EditWorkoutSessionSaved() => const DetailSkeleton(),
          EditWorkoutSessionLoadError() => ErrorCard(
            title: context.l10n.detailErrorTitle,
            message: context.l10n.detailErrorBody,
            onRetry: () => context.read<EditWorkoutSessionBloc>().add(
              EditWorkoutSessionLoaded(sessionId: sessionId),
            ),
          ),
          final EditWorkoutSessionEditable editable =>
            EditWorkoutSessionFormView(state: editable),
        },
      ),
    );
  }
}
