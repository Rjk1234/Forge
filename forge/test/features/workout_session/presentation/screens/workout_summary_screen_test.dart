import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/navigation/workout_data_refresher.dart';
import 'package:forge/features/workout_session/application/bloc/workout_summary_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/workout_summary_event.dart';
import 'package:forge/features/workout_session/application/bloc/workout_summary_state.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/presentation/screens/workout_summary_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

class _MockRefresher extends Mock implements WorkoutDataRefresher {}

class _MockBloc extends MockBloc<WorkoutSummaryEvent, WorkoutSummaryState>
    implements WorkoutSummaryBloc {}

final _session = WorkoutSession(
  sessionId: 's1',
  planId: 'p1',
  planName: 'Push Day — Upper Body',
  completedAt: DateTime(2026, 9, 7, 19, 30),
  startedAt: DateTime(2026, 9, 7, 18, 42),
  sessionDurationSec: 2880,
  sessionExercises: const [
    SessionExercise(
      exerciseId: 'e1',
      exerciseName: 'Barbell Bench Press',
      type: ExerciseType.weighted,
      actualSets: [
        ActualSet(repetitions: 8, weight: 60),
        ActualSet(repetitions: 7, weight: 60),
        ActualSet(skipped: true),
      ],
    ),
    SessionExercise(
      exerciseId: 'e2',
      exerciseName: 'Plank Hold',
      type: ExerciseType.timeBased,
      actualSets: [ActualSet(durationSec: 45)],
    ),
  ],
);

Widget _wrap(WorkoutSummaryBloc bloc) {
  return MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.darkTheme,
    routerConfig: GoRouter(
      initialLocation: '/workout/summary',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('Home stub')),
        GoRoute(
          path: '/history',
          builder: (_, _) => const Text('History stub'),
        ),
        GoRoute(
          path: '/workout/summary',
          builder: (_, _) => BlocProvider<WorkoutSummaryBloc>.value(
            value: bloc,
            child: const WorkoutSummaryScreen(),
          ),
        ),
      ],
    ),
  );
}

_MockBloc _blocIn(
  WorkoutSummaryState state, {
  Stream<WorkoutSummaryState>? stream,
}) {
  final bloc = _MockBloc();
  when(() => bloc.state).thenReturn(state);
  when(() => bloc.stream).thenAnswer((_) => stream ?? const Stream.empty());
  return bloc;
}

void main() {
  setUpAll(() {
    registerFallbackValue(const WorkoutSummaryRetryRequested());
  });

  group('WorkoutSummaryScreen — data refresh', () {
    late _MockRefresher refresher;

    setUp(() {
      refresher = _MockRefresher();
      if (getIt.isRegistered<WorkoutDataRefresher>()) {
        getIt.unregister<WorkoutDataRefresher>();
      }
      getIt.registerSingleton<WorkoutDataRefresher>(refresher);
    });

    tearDown(() => getIt.unregister<WorkoutDataRefresher>());

    testWidgets('a successful save refreshes the workout data once', (
      tester,
    ) async {
      final controller = StreamController<WorkoutSummaryState>.broadcast();
      final bloc = _blocIn(
        const WorkoutSummaryLoading(planName: 'Leg Day'),
        stream: controller.stream,
      );

      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();
      verifyNever(() => refresher.refresh());

      when(
        () => bloc.state,
      ).thenReturn(WorkoutSummarySuccess(session: _session));
      controller.add(WorkoutSummarySuccess(session: _session));
      await tester.pump();

      verify(() => refresher.refresh()).called(1);
      await controller.close();
    });
  });

  group('WorkoutSummaryScreen — loading', () {
    testWidgets('shows plan name, saving button and spinner', (tester) async {
      final bloc = _blocIn(const WorkoutSummaryLoading(planName: 'Leg Day'));

      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();

      expect(find.text('Leg Day'), findsOneWidget);
      expect(find.text(l10n.workoutSummaryLoadingButton), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(l10n.workoutSummaryDoneButton), findsNothing);
    });

    testWidgets('back gesture is blocked', (tester) async {
      final bloc = _blocIn(const WorkoutSummaryLoading(planName: 'Leg Day'));

      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Leg Day'), findsOneWidget);
    });
  });

  group('WorkoutSummaryScreen — success', () {
    Future<_MockBloc> pumpSuccess(WidgetTester tester) async {
      final bloc = _blocIn(WorkoutSummarySuccess(session: _session));
      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();
      return bloc;
    }

    testWidgets('shows hero, stats and exercise breakdown', (tester) async {
      await pumpSuccess(tester);

      expect(find.text(l10n.workoutSummaryAppBarTitle), findsOneWidget);
      expect(find.text('Push Day — Upper Body'), findsOneWidget);
      expect(find.text('Mon, Sep 7 · 6:42 PM'), findsOneWidget);
      expect(find.text('48 min'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Barbell Bench Press'), findsOneWidget);
      expect(find.text('8×60kg'), findsOneWidget);
      expect(find.text('Skipped'), findsOneWidget);
      expect(find.text('00:45'), findsOneWidget);
      expect(find.text('2 sets'), findsOneWidget);
      expect(find.text('1 set'), findsOneWidget);
    });

    testWidgets('Done goes home', (tester) async {
      await pumpSuccess(tester);

      await tester.tap(find.text(l10n.workoutSummaryDoneButton));
      await tester.pumpAndSettle();

      expect(find.text('Home stub'), findsOneWidget);
    });

    testWidgets('View History opens history', (tester) async {
      await pumpSuccess(tester);

      await tester.tap(find.text(l10n.workoutSummaryViewHistoryButton));
      await tester.pumpAndSettle();

      expect(find.text('History stub'), findsOneWidget);
    });

    testWidgets('back gesture is blocked', (tester) async {
      await pumpSuccess(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text(l10n.workoutSummaryDoneButton), findsOneWidget);
    });

    testWidgets('screen is wrapped in a PopScope that cannot pop', (
      tester,
    ) async {
      await pumpSuccess(tester);

      expect(
        find.ancestor(
          of: find.byType(Scaffold),
          matching: find.byWidgetPredicate((w) => w is PopScope && !w.canPop),
        ),
        findsWidgets,
      );
    });
  });

  group('WorkoutSummaryScreen — error', () {
    const error = WorkoutSummaryError(planName: 'Leg Day', sessionId: 's1');

    testWidgets('shows failure copy with the plan name and Retry', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_blocIn(error)));
      await tester.pump();

      expect(find.text(l10n.workoutSummaryErrorTitle), findsOneWidget);
      expect(
        find.text('Something went wrong writing "Leg Day" to local storage.'),
        findsOneWidget,
      );
      expect(find.text(l10n.workoutSummaryErrorNote), findsOneWidget);
      expect(find.text(l10n.workoutSummaryRetryButton), findsOneWidget);
    });

    testWidgets('an invalid log offers Done instead of Retry', (tester) async {
      const invalid = WorkoutSummaryError(
        planName: 'Leg Day',
        sessionId: 's1',
        isRetryable: false,
      );
      await tester.pumpWidget(_wrap(_blocIn(invalid)));
      await tester.pump();

      expect(find.text(l10n.workoutSummaryInvalidNote), findsOneWidget);
      expect(find.text(l10n.workoutSummaryRetryButton), findsNothing);

      await tester.tap(find.text(l10n.workoutSummaryDoneButton));
      await tester.pumpAndSettle();

      expect(find.text('Home stub'), findsOneWidget);
    });

    testWidgets('Retry dispatches a reload once', (tester) async {
      final bloc = _blocIn(error);
      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();

      final retry = find.text(l10n.workoutSummaryRetryButton);
      await tester.tap(retry);
      await tester.pump();

      verify(
        () => bloc.add(any(that: isA<WorkoutSummaryRetryRequested>())),
      ).called(1);
    });

    testWidgets('Retry is usable again after loading restarts and fails', (
      tester,
    ) async {
      final controller = StreamController<WorkoutSummaryState>.broadcast();
      final bloc = _blocIn(error, stream: controller.stream);
      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();

      await tester.tap(find.text(l10n.workoutSummaryRetryButton));
      await tester.pump();
      controller
        ..add(const WorkoutSummaryLoading(planName: 'Leg Day'))
        ..add(error);
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text(l10n.workoutSummaryRetryButton));
      await tester.pump();

      verify(
        () => bloc.add(any(that: isA<WorkoutSummaryRetryRequested>())),
      ).called(2);

      await controller.close();
    });

    testWidgets('back gesture is blocked', (tester) async {
      await tester.pumpWidget(_wrap(_blocIn(error)));
      await tester.pump();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text(l10n.workoutSummaryRetryButton), findsOneWidget);
    });
  });
}
