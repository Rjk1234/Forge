import 'package:forge/core/exceptions/app_exception.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/weekly_schedule.dart';
import '../repositories/schedule_repository.dart';

class GetWeeklyScheduleUseCase {
  const GetWeeklyScheduleUseCase({required this.repository});

  final ScheduleRepository repository;

  Future<Either<AppException, WeeklySchedule>> call() =>
      repository.getWeeklySchedule();
}
