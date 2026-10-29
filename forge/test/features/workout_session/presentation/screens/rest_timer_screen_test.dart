import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_plan/workout_plan.dart';
import 'package:forge/features/workout_session/application/bloc/rest_timer_args.dart';
import 'package:forge/features/workout_session/application/bloc/rest_timer_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/rest_timer_event.dart';
import 'package:forge/features/workout_session/application/bloc/rest_timer_state.dart';
import 'package:forge/features/workout_session/presentation/screens/rest_timer_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

class _MockRestTimerBloc extends MockBloc<RestTimerEvent, RestTimerState>
    implements RestTimerBloc {}

const _args = RestTimerArgs(
  restPeriodSec: 90,
  nextExercise: PlanExercise(
    exerciseId: 'a',
    exerciseName: 'Barbell Bench Press',
    type: ExerciseType.weighted,
    targetSets: 4,
    restPeriodSec: 90,
    targetRepetitions: 8,
    targetWeight: 60,
  ),
  nextSetNumber: 3,
);

Widget _wrap(RestTimerBloc bloc) {
  return MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.darkTheme,
    routerConfig: GoRouter(
      initialLocation: '/workout/active',
      routes: [
        GoRoute(
          path: '/workout/active',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/workout/rest'),
              child: const Text('Active stub'),
            ),
          ),
        ),
        GoRoute(
          path: '/workout/rest',
          builder: (_, _) => BlocProvider<RestTimerBloc>.value(
            value: bloc,
            child: const RestTimerScreen(upNext: _args),
          ),
        ),
      ],
    ),
  );
}

Future<void> _openRestTimer(WidgetTester tester, RestTimerBloc bloc) async {
  await tester.pumpWidget(_wrap(bloc));
  await tester.pump();
  await tester.tap(find.text('Active stub'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(const RestTimerSkipped());
  });

  testWidgets('renders MM:SS countdown, resting label, up next and skip', (
    tester,
  ) async {
    final bloc = _MockRestTimerBloc();
    when(
      () => bloc.state,
    ).thenReturn(const RestTimerRunning(totalSec: 90, remainingSec: 90));
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

    await _openRestTimer(tester, bloc);

    expect(find.text('01:30'), findsOneWidget);
    expect(find.text('RESTING'), findsOneWidget);
    expect(find.text(l10n.restTimerSkipRestButton), findsOneWidget);
    expect(find.text('Barbell Bench Press — Set 3 of 4'), findsOneWidget);
    expect(find.text('Target: 8 reps · 60 kg'), findsOneWidget);
  });

  testWidgets('countdown text follows the bloc state', (tester) async {
    final bloc = _MockRestTimerBloc();
    final controller = StreamController<RestTimerState>.broadcast();
    when(
      () => bloc.state,
    ).thenReturn(const RestTimerRunning(totalSec: 5, remainingSec: 5));
    when(() => bloc.stream).thenAnswer((_) => controller.stream);

    await _openRestTimer(tester, bloc);
    expect(find.text('00:05'), findsOneWidget);

    controller.add(const RestTimerRunning(totalSec: 5, remainingSec: 4));
    await tester.pumpAndSettle();
    expect(find.text('00:04'), findsOneWidget);

    await controller.close();
  });

  testWidgets('tapping Skip Rest dispatches RestTimerSkipped', (tester) async {
    final bloc = _MockRestTimerBloc();
    when(
      () => bloc.state,
    ).thenReturn(const RestTimerRunning(totalSec: 90, remainingSec: 60));
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

    await _openRestTimer(tester, bloc);
    await tester.tap(find.text(l10n.restTimerSkipRestButton));
    await tester.pump();

    verify(() => bloc.add(any(that: isA<RestTimerSkipped>()))).called(1);
  });

  testWidgets('OS back is treated as Skip and does not pop the route', (
    tester,
  ) async {
    final bloc = _MockRestTimerBloc();
    when(
      () => bloc.state,
    ).thenReturn(const RestTimerRunning(totalSec: 90, remainingSec: 60));
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

    await _openRestTimer(tester, bloc);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    verify(() => bloc.add(any(that: isA<RestTimerSkipped>()))).called(1);
    expect(find.text('01:00'), findsOneWidget);
  });

  testWidgets('pops back when navigateBack is emitted', (tester) async {
    final bloc = _MockRestTimerBloc();
    final controller = StreamController<RestTimerState>.broadcast();
    when(
      () => bloc.state,
    ).thenReturn(const RestTimerRunning(totalSec: 90, remainingSec: 60));
    when(() => bloc.stream).thenAnswer((_) => controller.stream);

    await _openRestTimer(tester, bloc);
    controller.add(
      const RestTimerRunning(totalSec: 90, remainingSec: 0, navigateBack: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('Active stub'), findsOneWidget);
    expect(find.text(l10n.restTimerSkipRestButton), findsNothing);

    await controller.close();
  });
}
