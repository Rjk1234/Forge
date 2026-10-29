import 'package:forge/core/exceptions/app_exception.dart';
import 'package:fpdart/fpdart.dart';

import '../repositories/schedule_repository.dart';

class SaveScheduleAssignmentUseCase {
  const SaveScheduleAssignmentUseCase({required this.repository});

  final ScheduleRepository repository;

  Future<Either<AppException, void>> call({
    required String planId,
    required String planName,
    required Set<int> previousWeekdays,
    required Set<int> newWeekdays,
  }) => repository.saveAssignment(
    planId: planId,
    planName: planName,
    previousWeekdays: previousWeekdays,
    newWeekdays: newWeekdays,
  );
}
