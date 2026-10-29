import 'package:forge/core/exceptions/app_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class AccountDataRepository {
  /// Deletes the profile, workout plans, schedules and workout history.
  ///
  /// The exercise catalogue is app data, not user data, and is kept. Either
  /// everything is deleted or nothing is.
  Future<Either<AppException, void>> clearUserData();
}
