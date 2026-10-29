import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/profile/data/datasources/account_data_local_data_source.dart';
import 'package:forge/features/profile/domain/repositories/account_data_repository.dart';
import 'package:fpdart/fpdart.dart';

class AccountDataRepositoryImpl implements AccountDataRepository {
  const AccountDataRepositoryImpl({required this.dataSource});

  final AccountDataLocalDataSource dataSource;

  @override
  Future<Either<AppException, void>> clearUserData() async {
    try {
      await dataSource.clearUserData();
      return const Right(null);
    } catch (e) {
      return Left(
        CacheException(
          message: "Couldn't clear your data",
          originalException: e,
        ),
      );
    }
  }
}
