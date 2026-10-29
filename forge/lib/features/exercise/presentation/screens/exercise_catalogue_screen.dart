import 'package:forge/features/workout_plan/presentation/screens/workout_plans_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/exercise/application/bloc/exercise_catalogue_bloc.dart';
import 'package:forge/features/exercise/application/bloc/exercise_catalogue_event.dart';
import 'package:forge/features/exercise/application/bloc/exercise_catalogue_state.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:forge/features/exercise/domain/entities/picker_context.dart';
import 'package:forge/features/exercise/presentation/widgets/exercise_skeleton_list.dart';
import 'package:forge/features/exercise/presentation/widgets/picker_banner.dart';
import 'package:forge/core/widgets/error_card.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/features/exercise/presentation/widgets/exercise_catalogue_content.dart';

class ExerciseCatalogueScreen extends StatelessWidget {
  static const String routeSegment = 'exercises';
  static const String routePath =
      '${WorkoutPlansScreen.routePath}/$routeSegment';
  static const String routeName = 'exerciseCatalogue';

  const ExerciseCatalogueScreen({this.pickerContext, super.key});

  final PickerContext? pickerContext;

  void _onSearchChanged(BuildContext context, String query) {
    context.read<ExerciseCatalogueBloc>().add(
      ExerciseCatalogueSearchChanged(query),
    );
  }

  void _onFilterChanged(BuildContext context, ExerciseType? type) {
    context.read<ExerciseCatalogueBloc>().add(
      ExerciseCatalogueFilterChanged(type),
    );
  }

  void _onRetry(BuildContext context) {
    context.read<ExerciseCatalogueBloc>().add(
      const ExerciseCatalogueLoadRequested(),
    );
  }

  void _onAddExercise(BuildContext context, Exercise exercise) {
    context.pop(exercise);
  }

  Widget _buildBody(BuildContext context, ExerciseCatalogueState state) {
    return switch (state) {
      ExerciseCatalogueInitial() ||
      ExerciseCatalogueLoading() => const ExerciseSkeletonList(),
      ExerciseCataloguePopulated(
        :final displayedExercises,
        :final query,
        :final activeFilter,
      ) =>
        _buildContent(context, displayedExercises, query, activeFilter),
      ExerciseCatalogueEmpty(:final query, :final activeFilter) =>
        _buildContent(context, const [], query, activeFilter),
      ExerciseCatalogueError() => ErrorCard(
        message: context.l10n.exerciseCatalogueLoadError,
        onRetry: () => _onRetry(context),
      ),
    };
  }

  Widget _buildContent(
    BuildContext context,
    List<Exercise> exercises,
    String query,
    ExerciseType? activeFilter,
  ) {
    return ExerciseCatalogueContent(
      exercises: exercises,
      query: query,
      activeFilter: activeFilter,
      isPickerMode: pickerContext != null,
      onSearchChanged: (query) => _onSearchChanged(context, query),
      onFilterChanged: (type) => _onFilterChanged(context, type),
      onAddTap: (exercise) => _onAddExercise(context, exercise),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.l10n.exerciseCatalogueTitle,
          style: textTheme.titleLarge,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (pickerContext != null)
              PickerBanner(planName: pickerContext!.planName),
            Expanded(
              child: BlocBuilder<ExerciseCatalogueBloc, ExerciseCatalogueState>(
                builder: _buildBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
