import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_detail_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_detail_event.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_detail_state.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/presentation/screens/workout_history_detail_screen.dart';
import 'package:forge/features/workout_session/presentation/widgets/detail_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

class _MockBloc
    extends MockBloc<WorkoutHistoryDetailEvent, WorkoutHistoryDetailState>
    implements WorkoutHistoryDetailBloc {}

final _session = WorkoutSession(
  sessionId: 's1',
  planId: 'p',
  planName: 'Push Day — Upper Body',
  completedAt: DateTime(2026, 9, 7, 19, 30),
  startedAt: DateTime(2026, 9, 7, 18, 42),
  sessionDurationSec: 2280,
  sessionExercises: const [
    SessionExercise(
      exerciseId: 'e1',
      exerciseName: 'Bench Press',
      type: ExerciseType.weighted,
      actualSets: [
        ActualSet(repetitions: 8, weight: 60),
        ActualSet(skipped: true),
      ],
    ),
    SessionExercise(
      exerciseId: 'e2',
      exerciseName: 'Push-Ups',
      type: ExerciseType.bodyweight,
      actualSets: [ActualSet(repetitions: 15)],
    ),
    SessionExercise(
      exerciseId: 'e3',
      exerciseName: 'Plank Hold',
      type: ExerciseType.timeBased,
      actualSets: [ActualSet(durationSec: 45)],
    ),
  ],
);

Widget _wrap(WorkoutHistoryDetailBloc bloc) {
  return MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.darkTheme,
    routerConfig: GoRouter(
      initialLocation: '/history',
      routes: [
        GoRoute(
          path: '/history',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/history/detail'),
              child: const Text('List stub'),
            ),
          ),
          routes: [
            GoRoute(
              path: 'detail',
              builder: (_, _) => BlocProvider<WorkoutHistoryDetailBloc>.value(
                value: bloc,
                child: const WorkoutHistoryDetailScreen(sessionId: 's1'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Future<void> _open(WidgetTester tester, WorkoutHistoryDetailBloc bloc) async {
  await tester.pumpWidget(_wrap(bloc));
  await tester.pump();
  await tester.tap(find.text('List stub'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

_MockBloc _blocIn(
  WorkoutHistoryDetailState state, {
  Stream<WorkoutHistoryDetailState>? stream,
}) {
  final bloc = _MockBloc();
  when(() => bloc.state).thenReturn(state);
  when(() => bloc.stream).thenAnswer((_) => stream ?? const Stream.empty());
  return bloc;
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const WorkoutHistoryDetailLoadRequested(sessionId: 's1'),
    );
  });

  testWidgets('Initial and Loading show the skeleton', (tester) async {
    await _open(tester, _blocIn(const WorkoutHistoryDetailInitial()));
    expect(find.byType(DetailSkeleton), findsOneWidget);
  });

  testWidgets('Loading shows the skeleton', (tester) async {
    await _open(tester, _blocIn(const WorkoutHistoryDetailLoading()));
    expect(find.byType(DetailSkeleton), findsOneWidget);
    expect(find.text(l10n.detailScreenTitle), findsOneWidget);
  });

  testWidgets('Success shows hero, dated meta, stats and exercise pills', (
    tester,
  ) async {
    await _open(
      tester,
      _blocIn(WorkoutHistoryDetailSuccess(session: _session)),
    );

    expect(find.text('Push Day — Upper Body'), findsOneWidget);
    expect(find.text('Mon, Sep 7, 2026 · 6:42 PM'), findsOneWidget);
    expect(find.text('38 min'), findsOneWidget);
    expect(find.text('3'), findsNWidgets(2));
    expect(find.text('PERFORMANCE'), findsOneWidget);
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('8×60kg'), findsOneWidget);
    expect(find.text('Skipped'), findsOneWidget);
    expect(find.text('15 reps'), findsOneWidget);
    expect(find.text('00:45'), findsOneWidget);
  });

  testWidgets('Success has no action buttons', (tester) async {
    await _open(
      tester,
      _blocIn(WorkoutHistoryDetailSuccess(session: _session)),
    );

    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('the app bar offers edit and delete actions', (tester) async {
    await _open(
      tester,
      _blocIn(WorkoutHistoryDetailSuccess(session: _session)),
    );

    expect(find.byTooltip(l10n.historyDetailEditTooltip), findsOneWidget);
    expect(find.byTooltip(l10n.historyDetailDeleteTooltip), findsOneWidget);
  });

  testWidgets('a session with no exercises still shows the stat row', (
    tester,
  ) async {
    final empty = WorkoutSession(
      sessionId: 's2',
      planId: 'p',
      planName: 'Empty',
      completedAt: DateTime(2026, 9, 7, 19),
      startedAt: DateTime(2026, 9, 7, 18),
      sessionDurationSec: 600,
      sessionExercises: const [],
    );
    await _open(tester, _blocIn(WorkoutHistoryDetailSuccess(session: empty)));

    expect(find.text('PERFORMANCE'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
  });

  testWidgets('Error shows copy and Retry, without raw text', (tester) async {
    await _open(tester, _blocIn(const WorkoutHistoryDetailError()));

    expect(find.text(l10n.detailErrorTitle), findsOneWidget);
    expect(find.text(l10n.detailErrorBody), findsOneWidget);
    expect(find.text(l10n.historyRetryLabel), findsOneWidget);
  });

  testWidgets('Retry dispatches a reload once', (tester) async {
    final bloc = _blocIn(const WorkoutHistoryDetailError());
    await _open(tester, bloc);
    clearInteractions(bloc);

    final retry = find.text(l10n.historyRetryLabel);
    await tester.tap(retry);
    await tester.pump();

    verify(() => bloc.add(any())).called(1);
  });

  testWidgets('Retry works again after the retry fails', (tester) async {
    final controller = StreamController<WorkoutHistoryDetailState>.broadcast();
    const error = WorkoutHistoryDetailError();
    final bloc = _blocIn(error, stream: controller.stream);
    await _open(tester, bloc);
    clearInteractions(bloc);

    await tester.tap(find.text(l10n.historyRetryLabel));
    await tester.pump();
    controller
      ..add(const WorkoutHistoryDetailLoading())
      ..add(error);
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text(l10n.historyRetryLabel));
    await tester.pump();

    verify(() => bloc.add(any())).called(2);

    await controller.close();
  });

  testWidgets('back returns to the list', (tester) async {
    await _open(
      tester,
      _blocIn(WorkoutHistoryDetailSuccess(session: _session)),
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('List stub'), findsOneWidget);
  });
}
