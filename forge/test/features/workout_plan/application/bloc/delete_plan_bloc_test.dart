import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_plan/application/bloc/delete_plan_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/delete_plan_event.dart';
import 'package:forge/features/workout_plan/application/bloc/delete_plan_state.dart';
import 'package:forge/features/workout_plan/domain/repositories/workout_plan_repository.dart';
import 'package:forge/features/workout_plan/domain/usecases/delete_workout_plan_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockWorkoutPlanRepository extends Mock implements WorkoutPlanRepository {}

DeletePlanBloc _makeBloc(WorkoutPlanRepository repo) =>
    DeletePlanBloc(deleteWorkoutPlan: DeleteWorkoutPlanUseCase(repo));

void main() {
  group('DeletePlanBloc', () {
    late MockWorkoutPlanRepository mockRepo;

    setUp(() {
      mockRepo = MockWorkoutPlanRepository();
    });

    test('initial state is DeletePlanConfirmation', () {
      final bloc = _makeBloc(mockRepo);
      expect(bloc.state, isA<DeletePlanConfirmation>());
      bloc.close();
    });

    blocTest<DeletePlanBloc, DeletePlanState>(
      'emits [Deleting, Success] when delete succeeds',
      setUp: () {
        when(
          () => mockRepo.deletePlan(any()),
        ).thenAnswer((_) async => const Right(null));
      },
      build: () => _makeBloc(mockRepo),
      act: (bloc) => bloc.add(const DeletePlanConfirmed(planId: 'plan-1')),
      expect: () => [isA<DeletePlanDeleting>(), isA<DeletePlanSuccess>()],
      verify: (_) {
        verify(() => mockRepo.deletePlan('plan-1')).called(1);
      },
    );

    blocTest<DeletePlanBloc, DeletePlanState>(
      'emits [Deleting, Failure] when delete fails',
      setUp: () {
        when(() => mockRepo.deletePlan(any())).thenAnswer(
          (_) async =>
              Left(CacheException(message: "Couldn't delete the plan")),
        );
      },
      build: () => _makeBloc(mockRepo),
      act: (bloc) => bloc.add(const DeletePlanConfirmed(planId: 'plan-1')),
      expect: () => [isA<DeletePlanDeleting>(), isA<DeletePlanFailure>()],
    );

    blocTest<DeletePlanBloc, DeletePlanState>(
      'retry: emits [Deleting, Success] from Failure state on second confirm',
      setUp: () {
        var callCount = 0;
        when(() => mockRepo.deletePlan(any())).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            return Left(CacheException(message: 'fail'));
          }
          return const Right(null);
        });
      },
      build: () => _makeBloc(mockRepo),
      act: (bloc) async {
        bloc.add(const DeletePlanConfirmed(planId: 'plan-1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const DeletePlanConfirmed(planId: 'plan-1'));
      },
      expect: () => [
        isA<DeletePlanDeleting>(),
        isA<DeletePlanFailure>(),
        isA<DeletePlanDeleting>(),
        isA<DeletePlanSuccess>(),
      ],
    );
  });
}
