import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/profile/domain/repositories/account_data_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Wipes everything the user created, for logout.
class ClearUserDataUseCase {
  const ClearUserDataUseCase({required this.repository});

  final AccountDataRepository repository;

  Future<Either<AppException, void>> call() => repository.clearUserData();
}
