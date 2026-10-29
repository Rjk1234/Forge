import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/home/application/usecases/get_dashboard_snapshot_usecase.dart';
import 'package:forge/features/home/domain/entities/dashboard_snapshot.dart';
import 'package:forge/features/home/domain/repositories/home_repository.dart';
import 'package:fpdart/fpdart.dart';

class _FakeSuccessRepo implements HomeRepository {
  @override
  Future<Either<AppException, DashboardSnapshot>>
  getDashboardSnapshot() async =>
      const Right(DashboardSnapshot(hasPlans: false));
}

class _FakeFailRepo implements HomeRepository {
  final AppException error;
  _FakeFailRepo(this.error);

  @override
  Future<Either<AppException, DashboardSnapshot>>
  getDashboardSnapshot() async => Left(error);
}

void main() {
  final failure = CacheException(message: 'test error');

  group('GetDashboardSnapshotUseCase', () {
    test('delegates to repository and returns Right on success', () async {
      final useCase = GetDashboardSnapshotUseCase(
        repository: _FakeSuccessRepo(),
      );
      final result = await useCase();
      expect(result.isRight(), isTrue);
    });

    test('returns Left when repository returns failure', () async {
      final useCase = GetDashboardSnapshotUseCase(
        repository: _FakeFailRepo(failure),
      );
      final result = await useCase();
      expect(result.isLeft(), isTrue);
    });
  });
}
