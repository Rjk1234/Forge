import 'package:fpdart/fpdart.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import '../../domain/repositories/home_repository.dart';

class GetDashboardSnapshotUseCase {
  const GetDashboardSnapshotUseCase({required this.repository});

  final HomeRepository repository;

  Future<Either<AppException, DashboardSnapshot>> call() =>
      repository.getDashboardSnapshot();
}
