import 'package:fpdart/fpdart.dart';

import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/profile/domain/entities/user_profile.dart';
import 'package:forge/features/profile/domain/repositories/profile_repository.dart';

class SaveProfileUseCase {
  const SaveProfileUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<AppException, UserProfile>> call(UserProfile profile) =>
      repository.saveProfile(profile);
}
