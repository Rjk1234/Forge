import 'package:fpdart/fpdart.dart';

import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:forge/features/profile/data/mappers/user_profile_mapper.dart';
import 'package:forge/features/profile/domain/entities/user_profile.dart';
import 'package:forge/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({required this.dataSource});

  final ProfileLocalDataSource dataSource;

  @override
  Future<Either<AppException, UserProfile>> getProfile() async {
    try {
      final model = await dataSource.getProfile();
      if (model == null) {
        return const Right(
          UserProfile(
            displayName: '',
            fitnessGoal: '',
            experienceLevel: 'Beginner',
            heightCm: 0,
            weightKg: 0,
          ),
        );
      }
      return Right(UserProfileMapper.fromRecord(model));
    } catch (e) {
      return Left(
        CacheException(
          message: "Couldn't load the profile",
          originalException: e,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, UserProfile>> saveProfile(
    UserProfile profile,
  ) async {
    try {
      final existing = await dataSource.getProfile();
      final model = UserProfileMapper.toRecord(
        profile,
        createdAt: existing?.createdAt,
      );
      await dataSource.saveProfile(model);
      return Right(profile);
    } catch (e) {
      return Left(
        CacheException(
          message: "Couldn't save the profile",
          originalException: e,
        ),
      );
    }
  }
}
