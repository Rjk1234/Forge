import 'package:forge/core/exceptions/app_exception.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/schedule_form_context.dart';
import '../entities/weekly_schedule.dart';

abstract class ScheduleRepository {
  Future<Either<AppException, WeeklySchedule>> getWeeklySchedule();

  Future<Either<AppException, ScheduleFormContext>> loadAssignmentContext(
    String planId,
  );

  Future<Either<AppException, void>> saveAssignment({
    required String planId,
    required String planName,
    required Set<int> previousWeekdays,
    required Set<int> newWeekdays,
  });

  Future<Either<AppException, void>> removeEntry(int weekday);
}
