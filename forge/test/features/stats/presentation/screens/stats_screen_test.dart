import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/navigation/stats_reload_notifier.dart';
import 'package:forge/features/stats/application/bloc/stats_bloc.dart';
import 'package:forge/features/stats/application/bloc/stats_event.dart';
import 'package:forge/features/stats/application/bloc/stats_state.dart';
import 'package:forge/features/stats/domain/entities/exercise_stat_row.dart';
import 'package:forge/features/stats/domain/entities/stats_data.dart';
import 'package:forge/features/stats/presentation/screens/stats_screen.dart';
import 'package:forge/features/stats/presentation/widgets/exercise_stat_card.dart';
import 'package:forge/features/stats/presentation/widgets/personal_bests_link_row.dart';
import 'package:forge/features/stats/presentation/widgets/stats_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

class _MockBloc extends MockBloc<StatsEvent, StatsState> implements StatsBloc {}

const _populated = StatsData(
  totalWorkoutsCompleted: 3,
  totalVolumeKg: 1000,
  totalDurationSec: 7200,
  avgDurationSec: 2400,
);

const _empty = StatsData(
  totalWorkoutsCompleted: 0,
  totalVolumeKg: 0,
  totalDurationSec: 0,
  avgDurationSec: null,
);

const _row = ExerciseStatRow(
  exerciseName: 'Bench',
  type: ExerciseType.weighted,
  sessionCount: 3,
  bestWeight: 65,
  bestReps: 0,
  bestDurationSec: 0,
);

Widget _wrap(StatsBloc bloc) => MaterialApp.router(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppTheme.darkTheme,
  routerConfig: GoRouter(
    initialLocation: '/stats',
    routes: [
      GoRoute(
        path: '/stats',
        builder: (_, _) => BlocProvider<StatsBloc>.value(
          value: bloc,
          child: const StatsScreen(),
        ),
        routes: [
          GoRoute(
            path: 'personal-bests',
            builder: (_, _) => const Text('PB stub'),
          ),
        ],
      ),
      GoRoute(path: '/plans', builder: (_, _) => const Text('Plans stub')),
    ],
  ),
);

_MockBloc _blocIn(StatsState state, {Stream<StatsState>? stream}) {
  final bloc = _MockBloc();
  when(() => bloc.state).thenReturn(state);
  when(() => bloc.stream).thenAnswer((_) => stream ?? const Stream.empty());
  return bloc;
}

void main() {
  late StatsReloadNotifier notifier;

  setUpAll(() {
    registerFallbackValue(const StatsLoadRequested());
  });

  setUp(() {
    notifier = StatsReloadNotifier();
    if (getIt.isRegistered<StatsReloadNotifier>()) {
      getIt.unregister<StatsReloadNotifier>();
    }
    getIt.registerSingleton<StatsReloadNotifier>(notifier);
  });

  tearDown(() {
    getIt.unregister<StatsReloadNotifier>();
  });

  testWidgets('Initial and Loading show the skeleton', (tester) async {
    await tester.pumpWidget(_wrap(_blocIn(const StatsInitial())));
    await tester.pump();
    expect(find.byType(StatsSkeleton), findsOneWidget);

    await tester.pumpWidget(_wrap(_blocIn(const StatsLoading())));
    await tester.pump();
    expect(find.byType(StatsSkeleton), findsOneWidget);
  });

  testWidgets('Loaded shows tiles, breakdown and Personal Bests', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(_blocIn(const StatsLoaded(stats: _populated, exercises: [_row]))),
    );
    await tester.pump();

    expect(find.text('WORKOUTS COMPLETED'.toUpperCase()), findsNothing);
    expect(find.text(l10n.statsWorkoutsCompleted), findsOneWidget);
    expect(find.text('EXERCISE BREAKDOWN'), findsOneWidget);
    expect(find.byType(ExerciseStatCard), findsOneWidget);
    expect(find.text('RECORDS'), findsOneWidget);
    expect(find.byType(PersonalBestsLinkRow), findsOneWidget);
  });

  testWidgets('breakdown section is hidden when there are no rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(_blocIn(const StatsLoaded(stats: _populated, exercises: []))),
    );
    await tester.pump();

    expect(find.text('EXERCISE BREAKDOWN'), findsNothing);
    expect(find.byType(PersonalBestsLinkRow), findsOneWidget);
  });

  testWidgets('Personal Bests row opens the personal bests route', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(_blocIn(const StatsLoaded(stats: _populated, exercises: [_row]))),
    );
    await tester.pump();

    await tester.tap(find.byType(PersonalBestsLinkRow));
    await tester.pumpAndSettle();

    expect(find.text('PB stub'), findsOneWidget);
  });

  testWidgets('Empty shows the prompt and hides breakdown and records', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(_blocIn(const StatsLoaded(stats: _empty, exercises: []))),
    );
    await tester.pump();

    expect(find.text(l10n.statsEmptyTitle), findsOneWidget);
    expect(find.text('EXERCISE BREAKDOWN'), findsNothing);
    expect(find.byType(PersonalBestsLinkRow), findsNothing);
  });

  testWidgets('the empty CTA goes to Plans', (tester) async {
    await tester.pumpWidget(
      _wrap(_blocIn(const StatsLoaded(stats: _empty, exercises: []))),
    );
    await tester.pump();

    await tester.tap(find.text(l10n.statsEmptyCta));
    await tester.pumpAndSettle();

    expect(find.text('Plans stub'), findsOneWidget);
  });

  testWidgets('Error shows copy and Retry; Retry dispatches once', (
    tester,
  ) async {
    final bloc = _blocIn(const StatsError());
    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();

    expect(find.text(l10n.statsErrorTitle), findsOneWidget);
    expect(find.text(l10n.statsErrorBody), findsOneWidget);
    clearInteractions(bloc);

    final retry = find.text(l10n.retryButton);
    await tester.tap(retry);
    await tester.pump();

    verify(() => bloc.add(any())).called(1);
  });

  testWidgets('Retry works again after loading finishes in error', (
    tester,
  ) async {
    final controller = StreamController<StatsState>.broadcast();
    final bloc = _blocIn(const StatsError(), stream: controller.stream);
    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();
    clearInteractions(bloc);

    await tester.tap(find.text(l10n.retryButton));
    await tester.pump();
    controller
      ..add(const StatsLoading())
      ..add(const StatsError());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text(l10n.retryButton));
    await tester.pump();

    verify(() => bloc.add(any())).called(2);

    await controller.close();
  });

  testWidgets('reloads on every tab re-entry', (tester) async {
    final bloc = _blocIn(const StatsLoading());
    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();

    notifier.notify();
    await tester.pump();
    verify(() => bloc.add(any(that: isA<StatsLoadRequested>()))).called(1);
  });
}
