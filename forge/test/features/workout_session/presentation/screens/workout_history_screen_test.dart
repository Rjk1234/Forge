import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/navigation/workout_history_reload_notifier.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_event.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_state.dart';
import 'package:forge/features/workout_session/application/models/history_month_group.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/presentation/screens/workout_history_screen.dart';
import 'package:forge/features/workout_session/presentation/widgets/history_card.dart';
import 'package:forge/features/workout_session/presentation/widgets/history_month_label.dart';
import 'package:forge/features/workout_session/presentation/widgets/history_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

class _MockBloc extends MockBloc<WorkoutHistoryEvent, WorkoutHistoryState>
    implements WorkoutHistoryBloc {}

WorkoutSession _session(String id, String name, DateTime startedAt) =>
    WorkoutSession(
      sessionId: id,
      planId: 'p',
      planName: name,
      completedAt: startedAt.add(const Duration(hours: 1)),
      startedAt: startedAt,
      sessionDurationSec: 2400,
      sessionExercises: const [],
    );

final _sept = _session('sept', 'Push Day', DateTime(2026, 9, 7, 18));
final _aug = _session('aug', 'Leg Day', DateTime(2026, 8, 31, 18));

Widget _wrap(WorkoutHistoryBloc bloc) {
  return MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.darkTheme,
    routerConfig: GoRouter(
      initialLocation: '/history',
      routes: [
        GoRoute(
          path: '/history',
          builder: (_, _) => BlocProvider<WorkoutHistoryBloc>.value(
            value: bloc,
            child: const WorkoutHistoryScreen(),
          ),
        ),
        GoRoute(
          path: '/history/detail',
          builder: (_, state) => Text('Detail ${state.extra}'),
        ),
      ],
    ),
  );
}

_MockBloc _blocIn(WorkoutHistoryState state) {
  final bloc = _MockBloc();
  when(() => bloc.state).thenReturn(state);
  when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
  return bloc;
}

void main() {
  late WorkoutHistoryReloadNotifier notifier;

  setUpAll(() {
    registerFallbackValue(const WorkoutHistoryLoadRequested());
  });

  setUp(() {
    notifier = WorkoutHistoryReloadNotifier();
    if (getIt.isRegistered<WorkoutHistoryReloadNotifier>()) {
      getIt.unregister<WorkoutHistoryReloadNotifier>();
    }
    getIt.registerSingleton<WorkoutHistoryReloadNotifier>(notifier);
  });

  tearDown(() {
    getIt.unregister<WorkoutHistoryReloadNotifier>();
  });

  testWidgets('Loading shows the skeleton', (tester) async {
    await tester.pumpWidget(_wrap(_blocIn(const WorkoutHistoryLoading())));
    await tester.pump();

    expect(find.byType(HistorySkeleton), findsOneWidget);
  });

  testWidgets('Initial also shows the skeleton, never a blank screen', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_blocIn(const WorkoutHistoryInitial())));
    await tester.pump();

    expect(find.byType(HistorySkeleton), findsOneWidget);
  });

  testWidgets('Success shows month labels and one card per session', (
    tester,
  ) async {
    final bloc = _blocIn(
      WorkoutHistorySuccess(
        groups: [
          HistoryMonthGroup(label: 'September 2026', sessions: [_sept]),
          HistoryMonthGroup(label: 'August 2026', sessions: [_aug]),
        ],
      ),
    );
    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();

    expect(find.byType(HistoryMonthLabel), findsNWidgets(2));
    expect(find.text('SEPTEMBER 2026'), findsOneWidget);
    expect(find.byType(HistoryCard), findsNWidgets(2));
    expect(find.text('Push Day'), findsOneWidget);
    expect(find.text('Leg Day'), findsOneWidget);
  });

  testWidgets('tapping a card opens detail with that exact session', (
    tester,
  ) async {
    final bloc = _blocIn(
      WorkoutHistorySuccess(
        groups: [
          HistoryMonthGroup(label: 'September 2026', sessions: [_sept]),
          HistoryMonthGroup(label: 'August 2026', sessions: [_aug]),
        ],
      ),
    );
    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();

    await tester.tap(find.text('Leg Day'));
    await tester.pumpAndSettle();

    expect(find.text('Detail aug'), findsOneWidget);
  });

  testWidgets('Empty shows the empty copy and no Retry', (tester) async {
    await tester.pumpWidget(_wrap(_blocIn(const WorkoutHistoryEmpty())));
    await tester.pump();

    expect(find.text(l10n.historyEmptyTitle), findsOneWidget);
    expect(find.text(l10n.historyEmptySubtitle), findsOneWidget);
    expect(find.text(l10n.historyRetryLabel), findsNothing);
    expect(find.text(l10n.historyErrorTitle), findsNothing);
  });

  testWidgets('Error shows the error copy with Retry and no empty copy', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_blocIn(const WorkoutHistoryError())));
    await tester.pump();

    expect(find.text(l10n.historyErrorTitle), findsOneWidget);
    expect(find.text(l10n.historyErrorBody), findsOneWidget);
    expect(find.text(l10n.historyRetryLabel), findsOneWidget);
    expect(find.text(l10n.historyEmptyTitle), findsNothing);
  });

  testWidgets('Retry requests a fresh load', (tester) async {
    final bloc = _blocIn(const WorkoutHistoryError());
    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();
    clearInteractions(bloc);

    await tester.tap(find.text(l10n.historyRetryLabel));
    await tester.pump();

    verify(
      () => bloc.add(any(that: isA<WorkoutHistoryLoadRequested>())),
    ).called(1);
  });

  testWidgets('reloads on every tab re-entry', (tester) async {
    final bloc = _blocIn(const WorkoutHistoryEmpty());
    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();

    notifier.notify();
    await tester.pump();

    verify(
      () => bloc.add(any(that: isA<WorkoutHistoryLoadRequested>())),
    ).called(1);
  });
}
