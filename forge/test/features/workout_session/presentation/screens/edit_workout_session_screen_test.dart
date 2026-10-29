import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/core/navigation/workout_data_refresher.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/features/workout_session/application/bloc/edit_workout_session_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/edit_workout_session_event.dart';
import 'package:forge/features/workout_session/application/use_cases/get_workout_history_detail_use_case.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/usecases/update_workout_session_usecase.dart';
import 'package:forge/features/workout_session/presentation/screens/edit_workout_session_screen.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/l10n.dart';

class _MockGetDetail extends Mock implements GetWorkoutHistoryDetailUseCase {}

class _MockUpdate extends Mock implements UpdateWorkoutSessionUseCase {}

class _MockRefresher extends Mock implements WorkoutDataRefresher {}

final _session = WorkoutSession(
  sessionId: 's1',
  planId: 'p1',
  planName: 'Push',
  completedAt: DateTime(2026, 9, 7, 19),
  startedAt: DateTime(2026, 9, 7, 18),
  sessionDurationSec: 3600,
  sessionExercises: const [
    SessionExercise(
      exerciseId: 'bench',
      exerciseName: 'Bench Press',
      type: ExerciseType.weighted,
      actualSets: [ActualSet(repetitions: 5, weight: 60)],
    ),
    SessionExercise(
      exerciseId: 'plank',
      exerciseName: 'Plank Hold',
      type: ExerciseType.timeBased,
      actualSets: [ActualSet(durationSec: 45)],
    ),
  ],
);

void main() {
  late _MockGetDetail getDetail;
  late _MockUpdate update;
  late _MockRefresher refresher;

  setUpAll(() => registerFallbackValue(_session));

  setUp(() {
    getDetail = _MockGetDetail();
    update = _MockUpdate();
    refresher = _MockRefresher();
    when(() => getDetail('s1')).thenAnswer((_) async => Right(_session));
    when(() => update(any())).thenAnswer((_) async => const Right(null));
    if (getIt.isRegistered<WorkoutDataRefresher>()) {
      getIt.unregister<WorkoutDataRefresher>();
    }
    getIt.registerSingleton<WorkoutDataRefresher>(refresher);
  });

  tearDown(() => getIt.unregister<WorkoutDataRefresher>());

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.darkTheme,
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, _) => TextButton(
                onPressed: () => context.push('/edit'),
                child: const Text('stub'),
              ),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (_, _) => BlocProvider(
                    create: (_) => EditWorkoutSessionBloc(
                      getDetail: getDetail,
                      updateSession: update,
                    )..add(const EditWorkoutSessionLoaded(sessionId: 's1')),
                    child: const EditWorkoutSessionScreen(sessionId: 's1'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('stub'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists exercises with the fields of each type', (tester) async {
    await open(tester);

    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Plank Hold'), findsOneWidget);
    expect(find.text(l10n.activeWorkoutRepsLabel), findsOneWidget);
    expect(find.text(l10n.activeWorkoutWeightLabel), findsOneWidget);
    expect(find.text(l10n.activeWorkoutDurationLabel), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.byType(Switch), findsNWidgets(2));
  });

  testWidgets('a valid edit saves, refreshes data and returns', (tester) async {
    await open(tester);

    await tester.enterText(find.byType(TextField).first, '9');
    await tester.tap(find.text(l10n.editSessionSaveButton));
    await tester.pumpAndSettle();

    final saved =
        verify(() => update(captureAny())).captured.single as WorkoutSession;
    expect(saved.sessionExercises.first.actualSets.single.repetitions, 9);
    verify(() => refresher.refresh()).called(1);
    expect(find.byType(EditWorkoutSessionScreen), findsNothing);
  });

  testWidgets('an invalid value shows an error and blocks the save', (
    tester,
  ) async {
    await open(tester);

    await tester.enterText(find.byType(TextField).first, '0');
    await tester.pump();
    await tester.tap(find.text(l10n.editSessionSaveButton));
    await tester.pump();

    expect(find.text(l10n.activeWorkoutRepsError(1000)), findsOneWidget);
    verifyNever(() => update(any()));
    verifyNever(() => refresher.refresh());
  });

  testWidgets('skipping every set shows the no-valid-set error', (
    tester,
  ) async {
    await open(tester);

    for (final toggle in tester.widgetList<Switch>(find.byType(Switch))) {
      toggle.onChanged!(true);
    }
    await tester.pump();
    await tester.tap(find.text(l10n.editSessionSaveButton));
    await tester.pump();

    expect(find.text(l10n.editSessionNoValidSetError), findsOneWidget);
    verifyNever(() => update(any()));
  });

  testWidgets('a failed save shows the error and a working Retry', (
    tester,
  ) async {
    when(
      () => update(any()),
    ).thenAnswer((_) async => Left(CacheException(message: 'disk')));
    await open(tester);

    await tester.tap(find.text(l10n.editSessionSaveButton));
    await tester.pumpAndSettle();
    expect(find.text(l10n.editSessionSaveError), findsOneWidget);

    when(() => update(any())).thenAnswer((_) async => const Right(null));
    await tester.tap(find.text(l10n.editSessionRetryButton));
    await tester.pumpAndSettle();

    verify(() => refresher.refresh()).called(1);
  });

  testWidgets('a load failure shows the error view', (tester) async {
    when(
      () => getDetail('s1'),
    ).thenAnswer((_) async => Left(CacheException(message: 'gone')));
    await open(tester);

    expect(find.text(l10n.detailErrorTitle), findsOneWidget);
  });
}
