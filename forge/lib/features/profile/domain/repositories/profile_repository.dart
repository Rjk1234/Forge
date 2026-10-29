import 'package:fpdart/fpdart.dart';

import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<AppException, UserProfile>> getProfile();
  Future<Either<AppException, UserProfile>> saveProfile(UserProfile profile);
}
