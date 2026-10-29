import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/navigation/progress_reload_notifier.dart';
import 'package:forge/features/progress/application/bloc/progress_bloc.dart';
import 'package:forge/features/progress/application/bloc/progress_event.dart';
import 'package:forge/features/progress/application/bloc/progress_state.dart';
import 'package:forge/features/progress/domain/entities/exercise_metrics.dart';
import 'package:forge/features/progress/domain/entities/exercise_progress_data.dart';
import 'package:forge/features/progress/presentation/screens/progress_screen.dart';
import 'package:forge/features/progress/presentation/widgets/exercise_chip.dart';
import 'package:forge/features/progress/presentation/widgets/progress_chart_card.dart';
import 'package:forge/features/progress/presentation/widgets/progress_empty_state.dart';
import 'package:forge/features/progress/presentation/widgets/progress_skeleton.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

class _MockBloc extends MockBloc<ProgressEvent, ProgressState>
    implements ProgressBloc {}

ExerciseProgressData _exercise(String name, {int sessions = 3}) =>
    ExerciseProgressData(
      exerciseName: name,
      type: ExerciseType.weighted,
      totalValidSessions: sessions,
      sessionDataPoints: [
        for (var i = 0; i < sessions; i++)
          ProgressDataPoint(
            sessionIndex: i + 1,
            metricValue: 50.0 + i,
            date: DateTime(2026, 9, 1 + i),
            isLatest: i == sessions - 1,
          ),
      ],
      latestMetrics: const WeightedMetrics(
        topWeight: 52,
        bestReps: 8,
        totalReps: 8,
        volume: 1000,
      ),
      latestWorkoutDurationSec: 0,
      deltaMetrics: sessions >= 2
          ? const WeightedMetrics(
              topWeight: 1,
              bestReps: 0,
              totalReps: 0,
              volume: 20,
            )
          : null,
    );

Widget _wrap(ProgressBloc bloc) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppTheme.darkTheme,
  home: BlocProvider<ProgressBloc>.value(
    value: bloc,
    child: const ProgressScreen(),
  ),
);

_MockBloc _blocIn(ProgressState state, {Stream<ProgressState>? stream}) {
  final bloc = _MockBloc();
  when(() => bloc.state).thenReturn(state);
  when(() => bloc.stream).thenAnswer((_) => stream ?? const Stream.empty());
  return bloc;
}

void main() {
  late ProgressReloadNotifier notifier;

  setUpAll(() {
    registerFallbackValue(const ProgressLoadRequested());
  });

  setUp(() {
    notifier = ProgressReloadNotifier();
    if (getIt.isRegistered<ProgressReloadNotifier>()) {
      getIt.unregister<ProgressReloadNotifier>();
    }
    getIt.registerSingleton<ProgressReloadNotifier>(notifier);
  });

  tearDown(() {
    getIt.unregister<ProgressReloadNotifier>();
  });

  testWidgets('Initial and Loading show the skeleton', (tester) async {
    await tester.pumpWidget(_wrap(_blocIn(const ProgressInitial())));
    await tester.pump();
    expect(find.byType(ProgressSkeleton), findsOneWidget);

    await tester.pumpWidget(_wrap(_blocIn(const ProgressLoading())));
    await tester.pump();
    expect(find.byType(ProgressSkeleton), findsOneWidget);
  });

  testWidgets('has no back arrow', (tester) async {
    await tester.pumpWidget(_wrap(_blocIn(const ProgressLoading())));
    await tester.pump();

    expect(find.byType(BackButton), findsNothing);
    expect(find.text(l10n.progressScreenTitle), findsOneWidget);
  });

  testWidgets('Loaded with enough sessions shows chips, chart and tiles', (
    tester,
  ) async {
    final bloc = _blocIn(
      ProgressLoaded(
        exercises: [_exercise('Bench'), _exercise('Squat')],
        selectedExerciseName: 'Bench',
      ),
    );
    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();

    expect(find.byType(ExerciseChip), findsNWidgets(2));
    expect(find.byType(ProgressChartCard), findsOneWidget);
    expect(find.text('LATEST SESSION'), findsOneWidget);
    expect(find.text('TOP WEIGHT'), findsOneWidget);
  });

  testWidgets('a selected exercise with one session shows the empty state', (
    tester,
  ) async {
    final bloc = _blocIn(
      ProgressLoaded(
        exercises: [_exercise('Bench'), _exercise('Squat', sessions: 1)],
        selectedExerciseName: 'Squat',
      ),
    );
    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();

    expect(find.byType(ProgressEmptyState), findsOneWidget);
    expect(find.byType(ProgressChartCard), findsNothing);
    expect(find.byType(ExerciseChip), findsNWidgets(2));
  });

  testWidgets('no exercises at all shows the empty state without chips', (
    tester,
  ) async {
    final bloc = _blocIn(
      const ProgressLoaded(exercises: [], selectedExerciseName: ''),
    );
    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();

    expect(find.byType(ProgressEmptyState), findsOneWidget);
    expect(find.byType(ExerciseChip), findsNothing);
  });

  testWidgets('tapping a chip dispatches ProgressExerciseSelected', (
    tester,
  ) async {
    final bloc = _blocIn(
      ProgressLoaded(
        exercises: [_exercise('Bench'), _exercise('Squat')],
        selectedExerciseName: 'Bench',
      ),
    );
    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();

    await tester.tap(find.text('Squat'));
    await tester.pump();

    verify(
      () => bloc.add(const ProgressExerciseSelected(exerciseName: 'Squat')),
    ).called(1);
  });

  testWidgets('Error shows the error card without chips', (tester) async {
    await tester.pumpWidget(_wrap(_blocIn(const ProgressError())));
    await tester.pump();

    expect(find.text(l10n.progressErrorTitle), findsOneWidget);
    expect(find.text(l10n.progressErrorBody), findsOneWidget);
    expect(find.byType(ExerciseChip), findsNothing);
  });

  testWidgets('Retry dispatches a reload', (tester) async {
    final bloc = _blocIn(const ProgressError());
    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();
    clearInteractions(bloc);

    final retry = find.text(l10n.retryButton);
    await tester.tap(retry);
    await tester.pump();

    verify(() => bloc.add(any())).called(1);
  });

  testWidgets('Retry works again once loading has finished', (tester) async {
    final controller = StreamController<ProgressState>.broadcast();
    final bloc = _blocIn(const ProgressError(), stream: controller.stream);
    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();
    clearInteractions(bloc);

    await tester.tap(find.text(l10n.retryButton));
    await tester.pump();
    controller
      ..add(const ProgressLoading())
      ..add(const ProgressError());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text(l10n.retryButton));
    await tester.pump();

    verify(() => bloc.add(any())).called(2);

    await controller.close();
  });

  testWidgets('reloads on every tab re-entry', (tester) async {
    final bloc = _blocIn(const ProgressLoading());
    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();

    notifier.notify();
    await tester.pump();
    verify(() => bloc.add(any(that: isA<ProgressLoadRequested>()))).called(1);
  });
}
