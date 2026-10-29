import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/exercise/application/bloc/exercise_catalogue_bloc.dart';
import 'package:forge/features/exercise/application/bloc/exercise_catalogue_event.dart';
import 'package:forge/features/exercise/application/bloc/exercise_catalogue_state.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:forge/features/exercise/domain/repositories/exercise_repository.dart';
import 'package:forge/features/exercise/domain/usecases/get_exercises_usecase.dart';
import 'package:fpdart/fpdart.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeRepo implements ExerciseRepository {
  final Either<AppException, List<Exercise>> Function() response;
  final Duration delay;

  _FakeRepo(this.response, {this.delay = Duration.zero});

  @override
  Future<Either<AppException, List<Exercise>>> getExercises() async {
    if (delay != Duration.zero) await Future<void>.delayed(delay);
    return response();
  }
}

ExerciseCatalogueBloc _bloc(
  Either<AppException, List<Exercise>> Function() response, {
  Duration delay = Duration.zero,
}) => ExerciseCatalogueBloc(
  getExercises: GetExercisesUseCase(
    repository: _FakeRepo(response, delay: delay),
  ),
);

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

final _weighted = Exercise(
  id: 'w1',
  name: 'Bench Press',
  type: ExerciseType.weighted,
);
final _timeBased = Exercise(
  id: 't1',
  name: 'Plank',
  type: ExerciseType.timeBased,
);
final _bodyweight = Exercise(
  id: 'b1',
  name: 'Push-up',
  type: ExerciseType.bodyweight,
);
final _allExercises = [_weighted, _timeBased, _bodyweight];
final _failure = CacheException(
  message: "Couldn't load the exercise catalogue",
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> _waitMs(int ms) =>
    Future<void>.delayed(Duration(milliseconds: ms));

void main() {
  group('ExerciseCatalogueBloc — Load scenarios (US1)', () {
    test('initial state is ExerciseCatalogueInitial', () {
      final bloc = _bloc(() => Right(_allExercises));
      expect(bloc.state, isA<ExerciseCatalogueInitial>());
      bloc.close();
    });

    test('emits [Loading, Populated] when repo returns exercises', () async {
      final bloc = _bloc(() => Right(_allExercises));
      final states = <ExerciseCatalogueState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ExerciseCatalogueLoadRequested());
      await _waitMs(50);

      expect(states.length, 2);
      expect(states[0], isA<ExerciseCatalogueLoading>());
      final populated = states[1] as ExerciseCataloguePopulated;
      expect(populated.displayedExercises, _allExercises);
      expect(populated.query, '');
      expect(populated.activeFilter, isNull);
      bloc.close();
    });

    test('emits [Loading, Empty] when repo returns empty list', () async {
      final bloc = _bloc(() => const Right([]));
      final states = <ExerciseCatalogueState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ExerciseCatalogueLoadRequested());
      await _waitMs(50);

      expect(states, [
        isA<ExerciseCatalogueLoading>(),
        isA<ExerciseCatalogueEmpty>(),
      ]);
      bloc.close();
    });

    test('emits [Loading, Error] when repo fails', () async {
      final bloc = _bloc(() => Left(_failure));
      final states = <ExerciseCatalogueState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ExerciseCatalogueLoadRequested());
      await _waitMs(50);

      expect(states.length, 2);
      expect(states[0], isA<ExerciseCatalogueLoading>());
      expect(states[1], isA<ExerciseCatalogueError>());
      bloc.close();
    });

    test('idempotent: second LoadRequested while Loading is ignored', () async {
      var callCount = 0;
      final bloc = _bloc(() {
        callCount++;
        return Right(_allExercises);
      }, delay: const Duration(milliseconds: 50));
      final states = <ExerciseCatalogueState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ExerciseCatalogueLoadRequested());
      bloc.add(const ExerciseCatalogueLoadRequested()); // should be ignored
      await _waitMs(150);

      expect(callCount, 1);
      expect(states, [
        isA<ExerciseCatalogueLoading>(),
        isA<ExerciseCataloguePopulated>(),
      ]);
      bloc.close();
    });
  });

  group('ExerciseCatalogueBloc — Search scenarios (US2)', () {
    ExerciseCatalogueBloc loadedBloc() {
      final bloc = _bloc(() => Right(_allExercises));
      bloc.add(const ExerciseCatalogueLoadRequested());
      return bloc;
    }

    test('search narrows by name substring (case-insensitive)', () async {
      final bloc = loadedBloc();
      await _waitMs(50);

      final states = <ExerciseCatalogueState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ExerciseCatalogueSearchChanged('bench'));
      await _waitMs(50);

      expect(states.last, isA<ExerciseCataloguePopulated>());
      final populated = states.last as ExerciseCataloguePopulated;
      expect(populated.displayedExercises, [_weighted]);
      expect(populated.query, 'bench');
      bloc.close();
    });

    test('search is case-insensitive', () async {
      final bloc = loadedBloc();
      await _waitMs(50);

      final states = <ExerciseCatalogueState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ExerciseCatalogueSearchChanged('BENCH'));
      await _waitMs(50);

      expect(states.last, isA<ExerciseCataloguePopulated>());
      final populated = states.last as ExerciseCataloguePopulated;
      expect(populated.displayedExercises, [_weighted]);
      bloc.close();
    });

    test('clearing search restores full list (for active filter)', () async {
      final bloc = loadedBloc();
      await _waitMs(50);

      bloc.add(const ExerciseCatalogueSearchChanged('bench'));
      await _waitMs(50);

      final states = <ExerciseCatalogueState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ExerciseCatalogueSearchChanged(''));
      await _waitMs(50);

      expect(states.last, isA<ExerciseCataloguePopulated>());
      final populated = states.last as ExerciseCataloguePopulated;
      expect(populated.displayedExercises, _allExercises);
      expect(populated.query, '');
      bloc.close();
    });

    test('search emits Empty when no results match', () async {
      final bloc = loadedBloc();
      await _waitMs(50);

      final states = <ExerciseCatalogueState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ExerciseCatalogueSearchChanged('zzzzz'));
      await _waitMs(50);

      expect(states.last, isA<ExerciseCatalogueEmpty>());
      final empty = states.last as ExerciseCatalogueEmpty;
      expect(empty.query, 'zzzzz');
      bloc.close();
    });
  });

  group('ExerciseCatalogueBloc — Filter scenarios (US2)', () {
    ExerciseCatalogueBloc loadedBloc() {
      final bloc = _bloc(() => Right(_allExercises));
      bloc.add(const ExerciseCatalogueLoadRequested());
      return bloc;
    }

    test('FilterChanged to weighted shows only weighted exercises', () async {
      final bloc = loadedBloc();
      await _waitMs(50);

      final states = <ExerciseCatalogueState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ExerciseCatalogueFilterChanged(ExerciseType.weighted));
      await _waitMs(50);

      expect(states.last, isA<ExerciseCataloguePopulated>());
      final populated = states.last as ExerciseCataloguePopulated;
      expect(populated.displayedExercises, [_weighted]);
      expect(populated.activeFilter, ExerciseType.weighted);
      bloc.close();
    });

    test('FilterChanged to null (All) restores full list', () async {
      final bloc = loadedBloc();
      await _waitMs(50);

      bloc.add(const ExerciseCatalogueFilterChanged(ExerciseType.weighted));
      await _waitMs(50);

      final states = <ExerciseCatalogueState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ExerciseCatalogueFilterChanged(null));
      await _waitMs(50);

      expect(states.last, isA<ExerciseCataloguePopulated>());
      final populated = states.last as ExerciseCataloguePopulated;
      expect(populated.displayedExercises, _allExercises);
      expect(populated.activeFilter, isNull);
      bloc.close();
    });

    test('filter emits Empty when type has no exercises', () async {
      final bloc = _bloc(
        () => Right([_weighted]), // only weighted
      );
      bloc.add(const ExerciseCatalogueLoadRequested());
      await _waitMs(50);

      final states = <ExerciseCatalogueState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ExerciseCatalogueFilterChanged(ExerciseType.bodyweight));
      await _waitMs(50);

      expect(states.last, isA<ExerciseCatalogueEmpty>());
      bloc.close();
    });
  });

  group('ExerciseCatalogueBloc — Combined search+filter (US2)', () {
    test('search within filtered type narrows correctly', () async {
      final bench = Exercise(
        id: 'w1',
        name: 'Bench Press',
        type: ExerciseType.weighted,
      );
      final squat = Exercise(
        id: 'w2',
        name: 'Squat',
        type: ExerciseType.weighted,
      );
      final plank = Exercise(
        id: 't1',
        name: 'Plank',
        type: ExerciseType.timeBased,
      );

      final bloc = _bloc(() => Right([bench, squat, plank]));
      bloc.add(const ExerciseCatalogueLoadRequested());
      await _waitMs(50);

      bloc.add(const ExerciseCatalogueFilterChanged(ExerciseType.weighted));
      await _waitMs(50);

      final states = <ExerciseCatalogueState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ExerciseCatalogueSearchChanged('bench'));
      await _waitMs(50);

      expect(states.last, isA<ExerciseCataloguePopulated>());
      final populated = states.last as ExerciseCataloguePopulated;
      expect(populated.displayedExercises, [bench]);
      expect(populated.activeFilter, ExerciseType.weighted);
      bloc.close();
    });

    test('clearing search keeps type filter active', () async {
      final bloc = _bloc(() => Right(_allExercises));
      bloc.add(const ExerciseCatalogueLoadRequested());
      await _waitMs(50);

      bloc.add(const ExerciseCatalogueFilterChanged(ExerciseType.weighted));
      await _waitMs(50);
      bloc.add(const ExerciseCatalogueSearchChanged('bench'));
      await _waitMs(50);

      final states = <ExerciseCatalogueState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ExerciseCatalogueSearchChanged(''));
      await _waitMs(50);

      expect(states.last, isA<ExerciseCataloguePopulated>());
      final populated = states.last as ExerciseCataloguePopulated;
      expect(populated.displayedExercises, [_weighted]);
      expect(populated.activeFilter, ExerciseType.weighted);
      bloc.close();
    });
  });

  group('ExerciseCatalogueBloc — Retry (US4)', () {
    test('LoadRequested from Error starts new load cycle', () async {
      var callCount = 0;
      final bloc = _bloc(() {
        callCount++;
        return callCount == 1 ? Left(_failure) : Right(_allExercises);
      });
      final states = <ExerciseCatalogueState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ExerciseCatalogueLoadRequested());
      await _waitMs(50);
      bloc.add(const ExerciseCatalogueLoadRequested()); // retry
      await _waitMs(50);

      expect(callCount, 2);
      expect(states, [
        isA<ExerciseCatalogueLoading>(),
        isA<ExerciseCatalogueError>(),
        isA<ExerciseCatalogueLoading>(),
        isA<ExerciseCataloguePopulated>(),
      ]);
      bloc.close();
    });

    test('idempotent guard does NOT block retry from Error', () async {
      var callCount = 0;
      final bloc = _bloc(() {
        callCount++;
        return Left(_failure);
      });
      final states = <ExerciseCatalogueState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ExerciseCatalogueLoadRequested());
      await _waitMs(50);

      // State is now Error — retry should be allowed
      expect(states.last, isA<ExerciseCatalogueError>());

      bloc.add(const ExerciseCatalogueLoadRequested());
      await _waitMs(50);

      expect(callCount, 2);
      expect(states, [
        isA<ExerciseCatalogueLoading>(),
        isA<ExerciseCatalogueError>(),
        isA<ExerciseCatalogueLoading>(),
        isA<ExerciseCatalogueError>(),
      ]);
      bloc.close();
    });
  });
}
