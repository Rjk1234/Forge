import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/home/application/bloc/home_bloc.dart';
import 'package:forge/features/home/application/bloc/home_event.dart';
import 'package:forge/features/home/application/bloc/home_state.dart';
import 'package:forge/features/home/application/usecases/get_dashboard_snapshot_usecase.dart';
import 'package:forge/features/home/domain/entities/dashboard_snapshot.dart';
import 'package:forge/features/home/domain/entities/today_workout.dart';
import 'package:forge/features/home/domain/repositories/home_repository.dart';
import 'package:fpdart/fpdart.dart';

class _FakeRepo implements HomeRepository {
  final Either<AppException, DashboardSnapshot> Function() response;
  final Duration delay;
  _FakeRepo(this.response, {this.delay = Duration.zero});

  @override
  Future<Either<AppException, DashboardSnapshot>> getDashboardSnapshot() async {
    if (delay != Duration.zero) await Future<void>.delayed(delay);
    return response();
  }
}

HomeBloc _bloc(
  Either<AppException, DashboardSnapshot> Function() response, {
  Duration delay = Duration.zero,
}) => HomeBloc(
  getDashboardSnapshot: GetDashboardSnapshotUseCase(
    repository: _FakeRepo(response, delay: delay),
  ),
);

const _empty = DashboardSnapshot(hasPlans: false);
const _restDay = DashboardSnapshot(hasPlans: true);
final _scheduled = DashboardSnapshot(
  hasPlans: true,
  todayWorkout: TodayWorkout(
    planId: 'plan-1',
    planName: 'Push Day',
    exerciseCount: 3,
    dominantType: ExerciseType.weighted,
    firstExerciseRestSec: 60,
  ),
);
final _failure = CacheException(message: "Couldn't load your dashboard");

void main() {
  group('HomeBloc', () {
    test('initial state is HomeInitial', () {
      final bloc = _bloc(() => const Right(_empty));
      expect(bloc.state, isA<HomeInitial>());
      bloc.close();
    });

    test(
      'emits [HomeLoading, HomePopulated] when there are no plans',
      () async {
        final bloc = _bloc(() => const Right(_empty));
        final states = <HomeState>[];
        bloc.stream.listen(states.add);

        bloc.add(const HomeLoadRequested());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states, [isA<HomeLoading>(), isA<HomePopulated>()]);
        bloc.close();
      },
    );

    test(
      'emits [HomeLoading, HomePopulated] for rest day (no todayWorkout)',
      () async {
        final bloc = _bloc(() => const Right(_restDay));
        final states = <HomeState>[];
        bloc.stream.listen(states.add);

        bloc.add(const HomeLoadRequested());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states.length, 2);
        expect(states[0], isA<HomeLoading>());
        final populated = states[1] as HomePopulated;
        expect(populated.snapshot.todayWorkout, isNull);
        bloc.close();
      },
    );

    test('emits [HomeLoading, HomePopulated] with scheduled workout', () async {
      final bloc = _bloc(() => Right(_scheduled));
      final states = <HomeState>[];
      bloc.stream.listen(states.add);

      bloc.add(const HomeLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states.length, 2);
      expect(states[0], isA<HomeLoading>());
      final populated = states[1] as HomePopulated;
      expect(populated.snapshot.todayWorkout?.planId, 'plan-1');
      bloc.close();
    });

    test('emits [HomeLoading, HomeError] when read fails', () async {
      final bloc = _bloc(() => Left(_failure));
      final states = <HomeState>[];
      bloc.stream.listen(states.add);

      bloc.add(const HomeLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states.length, 2);
      expect(states[0], isA<HomeLoading>());
      expect(states[1], isA<HomeError>());
      bloc.close();
    });

    test(
      'idempotent: second HomeLoadRequested while loading is ignored',
      () async {
        var callCount = 0;
        // Slow repo ensures event1 emits HomeLoading before event2 is processed.
        final bloc = _bloc(() {
          callCount++;
          return const Right(_empty);
        }, delay: const Duration(milliseconds: 50));
        final states = <HomeState>[];
        bloc.stream.listen(states.add);

        bloc.add(const HomeLoadRequested());
        bloc.add(const HomeLoadRequested()); // should be ignored
        await Future<void>.delayed(const Duration(milliseconds: 150));

        expect(callCount, 1);
        expect(states, [isA<HomeLoading>(), isA<HomePopulated>()]);
        bloc.close();
      },
    );

    test('retry: HomeLoadRequested from HomeError starts new cycle', () async {
      var callCount = 0;
      final bloc = _bloc(() {
        callCount++;
        return callCount == 1 ? Left(_failure) : const Right(_restDay);
      });
      final states = <HomeState>[];
      bloc.stream.listen(states.add);

      bloc.add(const HomeLoadRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const HomeLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states, [
        isA<HomeLoading>(),
        isA<HomeError>(),
        isA<HomeLoading>(),
        isA<HomePopulated>(),
      ]);
      bloc.close();
    });

    test(
      'a refresh from HomePopulated keeps the content and emits the update',
      () async {
        var calls = 0;
        final bloc = _bloc(
          () => Right(
            ++calls == 1
                ? _restDay
                : const DashboardSnapshot(hasPlans: true, hasSchedule: true),
          ),
        );
        final states = <HomeState>[];
        bloc.stream.listen(states.add);

        bloc.add(const HomeLoadRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HomeLoadRequested());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states, [
          isA<HomeLoading>(),
          isA<HomePopulated>(),
          isA<HomePopulated>().having(
            (s) => s.snapshot.hasSchedule,
            'hasSchedule',
            true,
          ),
        ]);
        bloc.close();
      },
    );
  });
}
