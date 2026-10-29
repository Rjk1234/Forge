import 'package:fpdart/fpdart.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({required this.localDataSource});

  final HomeDashboardLocalDataSource localDataSource;

  @override
  Future<Either<AppException, DashboardSnapshot>> getDashboardSnapshot() async {
    try {
      final snapshot = await localDataSource.getDashboardSnapshot();
      return Right(snapshot);
    } catch (e) {
      return Left(
        CacheException(
          message: "Couldn't load your dashboard",
          originalException: e,
        ),
      );
    }
  }
}
