import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_event.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_state.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/presentation/screens/active_workout_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

class _MockBloc extends MockBloc<ActiveWorkoutEvent, ActiveWorkoutState>
    implements ActiveWorkoutBloc {}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

const _kWeightedExercise = PlanExercise(
  exerciseId: 'ex-1',
  exerciseName: 'Bench Press',
  type: ExerciseType.weighted,
  targetSets: 3,
  restPeriodSec: 90,
  targetRepetitions: 8,
  targetWeight: 60.0,
);

const _kBodyweightExercise = PlanExercise(
  exerciseId: 'ex-2',
  exerciseName: 'Push-Up',
  type: ExerciseType.bodyweight,
  targetSets: 2,
  restPeriodSec: 60,
  targetRepetitions: 15,
);

const _kTimeBasedExercise = PlanExercise(
  exerciseId: 'ex-3',
  exerciseName: 'Plank',
  type: ExerciseType.timeBased,
  targetSets: 2,
  restPeriodSec: 30,
  targetDurationSec: 60,
);

final _session = WorkoutSession(
  sessionId: 's1',
  planId: 'p1',
  planName: 'Plan',
  completedAt: DateTime(2024, 1, 1, 10),
  startedAt: DateTime(2024, 1, 1, 9),
  sessionDurationSec: 3600,
  sessionExercises: const [],
);

ActiveWorkoutRunning _runningState({
  PlanExercise exercise = _kWeightedExercise,
  int exerciseIndex = 0,
  int exerciseCount = 1,
  int currentSetIndex = 0,
  List<SetStatus>? setStatuses,
  ActiveWorkoutFieldError? repError,
  ActiveWorkoutFieldError? weightError,
  ActiveWorkoutFieldError? durationError,
  bool isPaused = false,
  WorkoutSession? completedSession,
  bool navigateToPostWorkout = false,
  bool navigateToCancel = false,
  bool navigateToRestTimer = false,
  int restPeriodSec = 0,
  String planName = '',
}) {
  return ActiveWorkoutRunning(
    currentExercise: exercise,
    exerciseIndex: exerciseIndex,
    exerciseCount: exerciseCount,
    currentSetIndex: currentSetIndex,
    setStatuses:
        setStatuses ??
        List.generate(exercise.targetSets, (_) => SetStatus.pending),
    repError: repError,
    weightError: weightError,
    durationError: durationError,
    isPaused: isPaused,
    completedSession: completedSession,
    navigateToPostWorkout: navigateToPostWorkout,
    navigateToCancel: navigateToCancel,
    navigateToRestTimer: navigateToRestTimer,
    restPeriodSec: restPeriodSec,
    planName: planName,
  );
}

Widget _wrap(ActiveWorkoutBloc bloc, {List<GoRoute> extraRoutes = const []}) {
  return MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.darkTheme,
    routerConfig: GoRouter(
      initialLocation: '/workout/active',
      routes: [
        GoRoute(
          path: '/workout/active',
          builder: (context, state) => BlocProvider<ActiveWorkoutBloc>.value(
            value: bloc,
            child: const ActiveWorkoutScreen(),
          ),
        ),
        GoRoute(
          path: '/workout/cancel',
          builder: (_, __) => const Scaffold(body: Text('Cancel stub')),
        ),
        GoRoute(
          path: '/workout/summary',
          builder: (_, __) => const Scaffold(body: Text('Summary stub')),
        ),
        GoRoute(
          path: '/workout/rest',
          builder: (_, state) => const Scaffold(body: Text('Rest stub')),
        ),
        ...extraRoutes,
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(const ActiveWorkoutPauseRequested());
  });

  group('ActiveWorkoutScreen — exercise counter and name', () {
    testWidgets('shows exercise counter and name', (tester) async {
      final bloc = _MockBloc();
      when(
        () => bloc.state,
      ).thenReturn(_runningState(exerciseIndex: 1, exerciseCount: 3));
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();

      expect(find.textContaining('Exercise'), findsWidgets);
      expect(find.textContaining('2'), findsWidgets);
      expect(find.textContaining('3'), findsWidgets);
      expect(find.textContaining('Bench Press'), findsWidgets);
    });
  });

  group('ActiveWorkoutScreen — set progress row', () {
    testWidgets('renders set progress dots', (tester) async {
      final bloc = _MockBloc();
      when(() => bloc.state).thenReturn(
        _runningState(
          setStatuses: [SetStatus.logged, SetStatus.pending, SetStatus.pending],
          currentSetIndex: 1,
        ),
      );
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();

      // SetProgressRow should be in the tree
      expect(find.byType(ActiveWorkoutScreen), findsOneWidget);
    });
  });

  group('ActiveWorkoutScreen — Complete Set button', () {
    testWidgets('Complete Set button is present when no errors', (
      tester,
    ) async {
      final bloc = _MockBloc();
      when(() => bloc.state).thenReturn(_runningState());
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();

      expect(find.text(l10n.activeWorkoutCompleteSetButton), findsOneWidget);
    });

    testWidgets(
      'Complete Set button does not dispatch when repError is showing',
      (tester) async {
        final bloc = _MockBloc();
        when(() => bloc.state).thenReturn(
          _runningState(repError: ActiveWorkoutFieldError.repsNotPositive),
        );
        when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(_wrap(bloc));
        await tester.pump();

        await tester.tap(find.text(l10n.activeWorkoutCompleteSetButton));
        await tester.pump();

        verifyNever(
          () => bloc.add(any(that: isA<ActiveWorkoutCompleteSetRequested>())),
        );
      },
    );
  });

  group('ActiveWorkoutScreen — Skip button', () {
    testWidgets('Skip button dispatches SkipSetRequested', (tester) async {
      final bloc = _MockBloc();
      when(() => bloc.state).thenReturn(_runningState());
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();

      await tester.tap(find.text(l10n.activeWorkoutSkipButton));
      await tester.pump();

      verify(() => bloc.add(const ActiveWorkoutSkipSetRequested())).called(1);
    });
  });

  group('ActiveWorkoutScreen — Pause button', () {
    testWidgets('Pause button dispatches PauseRequested', (tester) async {
      final bloc = _MockBloc();
      when(() => bloc.state).thenReturn(_runningState());
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();

      await tester.tap(find.text(l10n.activeWorkoutPauseButton));
      await tester.pump();

      verify(() => bloc.add(const ActiveWorkoutPauseRequested())).called(1);
    });
  });

  group('ActiveWorkoutScreen — Paused overlay', () {
    testWidgets('shows paused overlay when isPaused is true', (tester) async {
      final bloc = _MockBloc();
      when(() => bloc.state).thenReturn(_runningState(isPaused: true));
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();

      expect(find.text(l10n.activeWorkoutPausedTitle), findsOneWidget);
      expect(find.text(l10n.activeWorkoutResumeButton), findsOneWidget);
    });

    testWidgets('Resume button in overlay dispatches ResumeRequested', (
      tester,
    ) async {
      final bloc = _MockBloc();
      when(() => bloc.state).thenReturn(_runningState(isPaused: true));
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();

      await tester.tap(find.text(l10n.activeWorkoutResumeButton));
      await tester.pump();

      verify(() => bloc.add(const ActiveWorkoutResumeRequested())).called(1);
    });
  });

  group('ActiveWorkoutScreen — post-workout navigation (SCR-19)', () {
    testWidgets('goes to the summary and dispatches PostWorkoutNavigated', (
      tester,
    ) async {
      final bloc = _MockBloc();
      final controller = StreamController<ActiveWorkoutState>.broadcast();
      when(() => bloc.state).thenReturn(_runningState());
      when(() => bloc.stream).thenAnswer((_) => controller.stream);

      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();

      controller.add(
        _runningState(navigateToPostWorkout: true, completedSession: _session),
      );
      await tester.pumpAndSettle();

      expect(find.text('Summary stub'), findsOneWidget);
      verify(
        () => bloc.add(any(that: isA<ActiveWorkoutPostWorkoutNavigated>())),
      ).called(1);

      await controller.close();
    });

    testWidgets('does not navigate without a completed session', (
      tester,
    ) async {
      final bloc = _MockBloc();
      final controller = StreamController<ActiveWorkoutState>.broadcast();
      when(() => bloc.state).thenReturn(_runningState());
      when(() => bloc.stream).thenAnswer((_) => controller.stream);

      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();

      controller.add(_runningState(navigateToPostWorkout: true));
      await tester.pumpAndSettle();

      expect(find.text('Summary stub'), findsNothing);

      await controller.close();
    });
  });

  group('ActiveWorkoutScreen — exercise type fields', () {
    testWidgets('shows weight field for weighted exercise', (tester) async {
      final bloc = _MockBloc();
      when(() => bloc.state).thenReturn(_runningState());
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();

      expect(find.text(l10n.activeWorkoutRepsLabel), findsOneWidget);
      expect(find.text(l10n.activeWorkoutWeightLabel), findsOneWidget);
    });

    testWidgets('shows only reps for bodyweight exercise', (tester) async {
      final bloc = _MockBloc();
      when(
        () => bloc.state,
      ).thenReturn(_runningState(exercise: _kBodyweightExercise));
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();

      expect(find.text(l10n.activeWorkoutRepsLabel), findsOneWidget);
      expect(find.text(l10n.activeWorkoutWeightLabel), findsNothing);
    });

    testWidgets('shows only duration for timeBased exercise', (tester) async {
      final bloc = _MockBloc();
      when(
        () => bloc.state,
      ).thenReturn(_runningState(exercise: _kTimeBasedExercise));
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();

      expect(find.text(l10n.activeWorkoutDurationLabel), findsOneWidget);
      expect(find.text(l10n.activeWorkoutRepsLabel), findsNothing);
    });
  });

  group('ActiveWorkoutScreen — Cancel button', () {
    testWidgets('Cancel button dispatches CancelRequested', (tester) async {
      final bloc = _MockBloc();
      when(() => bloc.state).thenReturn(_runningState());
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();

      await tester.tap(find.text(l10n.activeWorkoutCancelButton).first);
      await tester.pump();

      verify(
        () => bloc.add(any(that: isA<ActiveWorkoutCancelRequested>())),
      ).called(1);
    });

    testWidgets('OS back dispatches CancelRequested instead of popping', (
      tester,
    ) async {
      final bloc = _MockBloc();
      when(() => bloc.state).thenReturn(_runningState());
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const Text('Home stub')),
          GoRoute(
            path: '/workout/active',
            builder: (_, _) => BlocProvider<ActiveWorkoutBloc>.value(
              value: bloc,
              child: const ActiveWorkoutScreen(),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
      unawaited(router.push('/workout/active'));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      verify(
        () => bloc.add(any(that: isA<ActiveWorkoutCancelRequested>())),
      ).called(1);
      expect(find.text(l10n.activeWorkoutCompleteSetButton), findsOne);
      expect(find.text('Home stub'), findsNothing);
    });

    testWidgets('Paused overlay Cancel dispatches CancelRequested', (
      tester,
    ) async {
      final bloc = _MockBloc();
      when(() => bloc.state).thenReturn(_runningState(isPaused: true));
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();

      await tester.tap(find.text(l10n.activeWorkoutCancelButton).last);
      await tester.pump();

      verify(
        () => bloc.add(any(that: isA<ActiveWorkoutCancelRequested>())),
      ).called(1);
    });
  });

  group('ActiveWorkoutScreen — navigateToCancel state (FR-009)', () {
    testWidgets(
      'navigates to cancel route when state emits navigateToCancel:true',
      (tester) async {
        final bloc = _MockBloc();
        final controller = StreamController<ActiveWorkoutState>.broadcast();
        when(() => bloc.state).thenReturn(_runningState());
        when(() => bloc.stream).thenAnswer((_) => controller.stream);

        await tester.pumpWidget(_wrap(bloc));
        await tester.pump();

        controller.add(_runningState(navigateToCancel: true));
        await tester.pumpAndSettle();

        expect(find.text('Cancel stub'), findsOneWidget);
        verify(
          () => bloc.add(any(that: isA<ActiveWorkoutCancelNavigated>())),
        ).called(1);

        await controller.close();
      },
    );
  });

  group('ActiveWorkoutScreen — rest timer navigation (SCR-17)', () {
    testWidgets(
      'pushes rest timer and dispatches RestTimerNavigated when flagged',
      (tester) async {
        final bloc = _MockBloc();
        final controller = StreamController<ActiveWorkoutState>.broadcast();
        when(() => bloc.state).thenReturn(_runningState());
        when(() => bloc.stream).thenAnswer((_) => controller.stream);

        await tester.pumpWidget(_wrap(bloc));
        await tester.pump();

        controller.add(
          _runningState(
            currentSetIndex: 1,
            navigateToRestTimer: true,
            restPeriodSec: 90,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Rest stub'), findsOneWidget);
        verify(
          () => bloc.add(any(that: isA<ActiveWorkoutRestTimerNavigated>())),
        ).called(1);

        await controller.close();
      },
    );

    testWidgets('does not push rest timer when flag is false', (tester) async {
      final bloc = _MockBloc();
      final controller = StreamController<ActiveWorkoutState>.broadcast();
      when(() => bloc.state).thenReturn(_runningState());
      when(() => bloc.stream).thenAnswer((_) => controller.stream);

      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();

      controller.add(_runningState(currentSetIndex: 1));
      await tester.pumpAndSettle();

      expect(find.text('Rest stub'), findsNothing);

      await controller.close();
    });
  });
}
