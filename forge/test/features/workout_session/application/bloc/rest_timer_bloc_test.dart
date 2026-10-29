import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/workout_session/application/bloc/rest_timer_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/rest_timer_event.dart';
import 'package:forge/features/workout_session/application/bloc/rest_timer_state.dart';

Matcher _running(int total, int remaining, {required bool navigateBack}) =>
    isA<RestTimerRunning>()
        .having((s) => s.totalSec, 'totalSec', total)
        .having((s) => s.remainingSec, 'remainingSec', remaining)
        .having((s) => s.navigateBack, 'navigateBack', navigateBack);

void main() {
  group('RestTimerBloc', () {
    blocTest<RestTimerBloc, RestTimerState>(
      'natural expiry counts down to zero and sets navigateBack',
      build: RestTimerBloc.new,
      act: (bloc) {
        bloc
          ..add(const RestTimerStarted(restPeriodSec: 3))
          ..add(const RestTimerTicked())
          ..add(const RestTimerTicked())
          ..add(const RestTimerTicked());
      },
      expect: () => [
        _running(3, 3, navigateBack: false),
        _running(3, 2, navigateBack: false),
        _running(3, 1, navigateBack: false),
        _running(3, 0, navigateBack: true),
      ],
    );

    blocTest<RestTimerBloc, RestTimerState>(
      'skip immediately sets navigateBack with full remaining time',
      build: RestTimerBloc.new,
      act: (bloc) {
        bloc
          ..add(const RestTimerStarted(restPeriodSec: 90))
          ..add(const RestTimerSkipped());
      },
      expect: () => [
        _running(90, 90, navigateBack: false),
        _running(90, 90, navigateBack: true),
      ],
    );

    blocTest<RestTimerBloc, RestTimerState>(
      'skip mid-countdown keeps the current remainingSec',
      build: RestTimerBloc.new,
      act: (bloc) {
        bloc.add(const RestTimerStarted(restPeriodSec: 90));
        for (var i = 0; i < 5; i++) {
          bloc.add(const RestTimerTicked());
        }
        bloc.add(const RestTimerSkipped());
      },
      skip: 5,
      expect: () => [
        _running(90, 85, navigateBack: false),
        _running(90, 85, navigateBack: true),
      ],
    );

    blocTest<RestTimerBloc, RestTimerState>(
      'ticked while initial is a no-op',
      build: RestTimerBloc.new,
      act: (bloc) => bloc.add(const RestTimerTicked()),
      expect: () => <RestTimerState>[],
    );

    blocTest<RestTimerBloc, RestTimerState>(
      'repeated skips emit navigateBack only once',
      build: RestTimerBloc.new,
      act: (bloc) {
        bloc
          ..add(const RestTimerStarted(restPeriodSec: 30))
          ..add(const RestTimerSkipped())
          ..add(const RestTimerSkipped())
          ..add(const RestTimerSkipped());
      },
      expect: () => [
        _running(30, 30, navigateBack: false),
        _running(30, 30, navigateBack: true),
      ],
    );

    testWidgets('real timer ticks once per second and stops on close', (
      tester,
    ) async {
      final bloc = RestTimerBloc()
        ..add(const RestTimerStarted(restPeriodSec: 5));
      await tester.pump(const Duration(milliseconds: 1200));
      expect((bloc.state as RestTimerRunning).remainingSec, 4);

      unawaited(bloc.close());
      await tester.pump();
      final afterClose = bloc.state;
      await tester.pump(const Duration(seconds: 3));
      expect(bloc.state, afterClose);
    });
  });
}
