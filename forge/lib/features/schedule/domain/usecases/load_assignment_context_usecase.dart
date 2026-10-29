import 'package:forge/core/exceptions/app_exception.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/schedule_form_context.dart';
import '../repositories/schedule_repository.dart';

class LoadAssignmentContextUseCase {
  const LoadAssignmentContextUseCase({required this.repository});

  final ScheduleRepository repository;

  Future<Either<AppException, ScheduleFormContext>> call(String planId) {
    return repository.loadAssignmentContext(planId);
  }
}
