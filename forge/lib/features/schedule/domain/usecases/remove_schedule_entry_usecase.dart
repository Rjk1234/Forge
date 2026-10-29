import 'package:forge/core/exceptions/app_exception.dart';
import 'package:fpdart/fpdart.dart';

import '../repositories/schedule_repository.dart';

class RemoveScheduleEntryUseCase {
  const RemoveScheduleEntryUseCase({required this.repository});

  final ScheduleRepository repository;

  Future<Either<AppException, void>> call(int weekday) =>
      repository.removeEntry(weekday);
}
