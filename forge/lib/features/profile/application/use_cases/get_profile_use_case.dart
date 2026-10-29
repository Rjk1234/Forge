import 'package:fpdart/fpdart.dart';

import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/profile/domain/entities/user_profile.dart';
import 'package:forge/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  const GetProfileUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<AppException, UserProfile>> call() => repository.getProfile();
}
