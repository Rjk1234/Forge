import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_plan/application/bloc/pre_start_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/pre_start_event.dart';
import 'package:forge/features/workout_plan/application/bloc/pre_start_state.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/features/workout_plan/presentation/screens/workout_pre_start_screen.dart';
import 'package:forge/features/workout_plan/presentation/widgets/exercise_preview_card.dart';
import 'package:forge/features/workout_plan/presentation/widgets/pre_start_error_state.dart';
import 'package:forge/features/workout_plan/presentation/widgets/pre_start_skeleton.dart';
import 'package:forge/features/workout_plan/presentation/widgets/pre_start_unavailable_state.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

class MockPreStartBloc extends MockBloc<PreStartEvent, PreStartState>
    implements PreStartBloc {}

Widget _wrap(PreStartBloc bloc, {String planId = 'p1', int? weekday}) {
  return MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.darkTheme,
    routerConfig: GoRouter(
      initialLocation: '/test',
      routes: [
        GoRoute(
          path: '/test',
          builder: (context, state) => BlocProvider<PreStartBloc>.value(
            value: bloc,
            child: WorkoutPreStartScreen(
              planId: planId,
              scheduledWeekday: weekday,
            ),
          ),
        ),
        GoRoute(
          path: '/workout/active',
          builder: (context, state) => Scaffold(
            body: Text(
              'Active Workout ${(state.extra as WorkoutPlanDetail?)?.name}',
            ),
          ),
        ),
      ],
    ),
  );
}

WorkoutPlanDetail _loadedPlan() => WorkoutPlanDetail(
  id: 'p1',
  name: 'Push Day',
  createdAt: DateTime(2024, 1, 1),
  exercises: const [
    PlanExercise(
      exerciseId: 'ex-1',
      exerciseName: 'Bench Press',
      type: ExerciseType.weighted,
      targetSets: 4,
      restPeriodSec: 90,
      targetRepetitions: 8,
      targetWeight: 60.0,
    ),
    PlanExercise(
      exerciseId: 'ex-2',
      exerciseName: 'Push-Up',
      type: ExerciseType.bodyweight,
      targetSets: 3,
      restPeriodSec: 60,
      targetRepetitions: 15,
    ),
  ],
);

void main() {
  setUpAll(() {
    registerFallbackValue(const PreStartRequested(planId: ''));
    registerFallbackValue(const PreStartRetried(planId: ''));
  });

  group('WorkoutPreStartScreen — State A: Loading', () {
    late MockPreStartBloc bloc;

    setUp(() {
      bloc = MockPreStartBloc();
      when(() => bloc.state).thenReturn(const PreStartLoading());
      whenListen(
        bloc,
        Stream<PreStartState>.fromIterable([const PreStartLoading()]),
        initialState: const PreStartLoading(),
      );
    });

    tearDown(() => bloc.close());

    testWidgets('shows PreStartSkeleton', (tester) async {
      await tester.pumpWidget(_wrap(bloc));
      expect(find.byType(PreStartSkeleton), findsOneWidget);
    });

    testWidgets('does not show Begin Workout button', (tester) async {
      await tester.pumpWidget(_wrap(bloc));
      expect(find.text(l10n.preStartBeginButton), findsNothing);
    });
  });

  group('WorkoutPreStartScreen — State B: Loaded', () {
    late MockPreStartBloc bloc;

    setUp(() {
      bloc = MockPreStartBloc();
      final loadedState = PreStartLoaded(
        plan: _loadedPlan(),
        scheduledWeekday: null,
        isScheduledForToday: false,
      );
      when(() => bloc.state).thenReturn(loadedState);
      whenListen(
        bloc,
        Stream<PreStartState>.fromIterable([loadedState]),
        initialState: loadedState,
      );
    });

    tearDown(() => bloc.close());

    testWidgets('shows plan name', (tester) async {
      await tester.pumpWidget(_wrap(bloc));
      expect(find.text('Push Day'), findsOneWidget);
    });

    testWidgets('shows Begin Workout button', (tester) async {
      await tester.pumpWidget(_wrap(bloc));
      expect(find.text(l10n.preStartBeginButton), findsOneWidget);
    });

    testWidgets('Begin Workout opens the active workout with the plan', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(bloc));

      await tester.tap(find.text(l10n.preStartBeginButton));
      await tester.pumpAndSettle();

      expect(find.text('Active Workout Push Day'), findsOneWidget);
    });

    testWidgets('shows exercises section label', (tester) async {
      await tester.pumpWidget(_wrap(bloc));
      expect(find.text(l10n.preStartExercisesSectionLabel), findsOneWidget);
    });

    testWidgets('renders one ExercisePreviewCard per exercise', (tester) async {
      await tester.pumpWidget(_wrap(bloc));
      expect(find.byType(ExercisePreviewCard), findsNWidgets(2));
    });

    testWidgets('meta line shows exercise count only when no weekday', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(bloc));
      expect(find.textContaining('exercises'), findsOneWidget);
      expect(find.textContaining('Today'), findsNothing);
    });

    testWidgets(
      'meta line shows weekday and Today when isScheduledForToday=true',
      (tester) async {
        final today = DateTime.now().weekday;
        final todayState = PreStartLoaded(
          plan: _loadedPlan(),
          scheduledWeekday: today,
          isScheduledForToday: true,
        );
        when(() => bloc.state).thenReturn(todayState);
        whenListen(
          bloc,
          Stream<PreStartState>.fromIterable([todayState]),
          initialState: todayState,
        );
        await tester.pumpWidget(_wrap(bloc, weekday: today));
        expect(find.textContaining('· Today ·'), findsOneWidget);
      },
    );
  });

  group('WorkoutPreStartScreen — State C: Unavailable', () {
    late MockPreStartBloc bloc;

    setUp(() {
      bloc = MockPreStartBloc();
      when(() => bloc.state).thenReturn(const PreStartUnavailable());
      whenListen(
        bloc,
        Stream<PreStartState>.fromIterable([const PreStartUnavailable()]),
        initialState: const PreStartUnavailable(),
      );
    });

    tearDown(() => bloc.close());

    testWidgets('shows PreStartUnavailableState widget', (tester) async {
      await tester.pumpWidget(_wrap(bloc));
      expect(find.byType(PreStartUnavailableState), findsOneWidget);
    });

    testWidgets('shows unavailable title', (tester) async {
      await tester.pumpWidget(_wrap(bloc));
      expect(find.text(l10n.preStartUnavailableTitle), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(_wrap(bloc));
      expect(find.text(l10n.preStartBackToScheduleButton), findsOneWidget);
    });

    testWidgets('does not show Begin Workout', (tester) async {
      await tester.pumpWidget(_wrap(bloc));
      expect(find.text(l10n.preStartBeginButton), findsNothing);
    });
  });

  group('WorkoutPreStartScreen — State D: Error', () {
    late MockPreStartBloc bloc;

    setUp(() {
      bloc = MockPreStartBloc();
      when(() => bloc.state).thenReturn(const PreStartError());
      whenListen(
        bloc,
        Stream<PreStartState>.fromIterable([const PreStartError()]),
        initialState: const PreStartError(),
      );
    });

    tearDown(() => bloc.close());

    testWidgets('shows PreStartErrorState widget', (tester) async {
      await tester.pumpWidget(_wrap(bloc));
      expect(find.byType(PreStartErrorState), findsOneWidget);
    });

    testWidgets('shows error title', (tester) async {
      await tester.pumpWidget(_wrap(bloc));
      expect(find.text(l10n.preStartErrorTitle), findsOneWidget);
    });

    testWidgets('shows Retry button', (tester) async {
      await tester.pumpWidget(_wrap(bloc));
      expect(find.text(l10n.preStartRetryButton), findsOneWidget);
    });

    testWidgets('Retry dispatches PreStartRetried', (tester) async {
      await tester.pumpWidget(_wrap(bloc));
      await tester.tap(find.text(l10n.preStartRetryButton));
      await tester.pump();
      verify(
        () => bloc.add(
          const PreStartRetried(planId: 'p1', scheduledWeekday: null),
        ),
      ).called(1);
    });

    testWidgets('does not show Begin Workout', (tester) async {
      await tester.pumpWidget(_wrap(bloc));
      expect(find.text(l10n.preStartBeginButton), findsNothing);
    });
  });
}
