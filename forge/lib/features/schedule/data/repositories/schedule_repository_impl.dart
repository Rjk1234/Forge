import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/schedule/data/datasources/schedule_local_data_source.dart';
import 'package:forge/features/schedule/domain/entities/schedule_day.dart';
import 'package:forge/features/schedule/domain/entities/schedule_form_context.dart';
import 'package:forge/features/schedule/domain/entities/weekly_schedule.dart';
import 'package:forge/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:forge/features/workout_plan/data/datasources/workout_plan_local_data_source.dart';
import 'package:fpdart/fpdart.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  const ScheduleRepositoryImpl({
    required this.scheduleDataSource,
    required this.planDataSource,
  });

  final ScheduleLocalDataSource scheduleDataSource;
  final WorkoutPlanLocalDataSource planDataSource;

  @override
  Future<Either<AppException, WeeklySchedule>> getWeeklySchedule() async {
    try {
      final entries = await scheduleDataSource.getAllEntries();
      final entryByWeekday = {for (final e in entries) e.weekday: e};

      final now = DateTime.now();
      final todayWeekday = now.weekday;
      final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));

      final days = <ScheduleDay>[];

      for (var i = 0; i < 7; i++) {
        final weekday = i + 1;
        final date = monday.add(Duration(days: i));
        final entry = entryByWeekday[weekday];

        ScheduledPlanRef? assignedPlan;

        if (entry != null) {
          final plan = await planDataSource.getPlanById(entry.planId);
          if (plan != null) {
            assignedPlan = ScheduledPlanRef(
              planId: plan.planId,
              planName: plan.name,
              recurrenceLabel: 'Weekly',
            );
          }
        }

        days.add(
          ScheduleDay(
            weekday: weekday,
            date: date,
            isToday: weekday == todayWeekday,
            assignedPlan: assignedPlan,
          ),
        );
      }

      return Right(WeeklySchedule(days: days));
    } catch (e) {
      return Left(
        CacheException(
          message: "Couldn't load your schedule",
          originalException: e,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, ScheduleFormContext>> loadAssignmentContext(
    String planId,
  ) async {
    try {
      final plan = await planDataSource.getPlanById(planId);
      if (plan == null) {
        return Right(
          ScheduleFormContext(
            planId: planId,
            planName: null,
            currentDays: const {},
            occupiedDays: const {},
          ),
        );
      }

      final entries = await scheduleDataSource.getAllEntries();
      final currentDays = <int>{
        for (final e in entries)
          if (e.planId == planId) e.weekday,
      };
      final occupiedDays = <int, String>{};
      for (final entry in entries.where((e) => e.planId != planId)) {
        final occupant = await planDataSource.getPlanById(entry.planId);
        occupiedDays[entry.weekday] = occupant?.name ?? entry.planName;
      }

      return Right(
        ScheduleFormContext(
          planId: planId,
          planName: plan.name,
          currentDays: currentDays,
          occupiedDays: occupiedDays,
        ),
      );
    } catch (e) {
      return Left(
        CacheException(
          message: "Couldn't load this schedule",
          originalException: e,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, void>> removeEntry(int weekday) async {
    try {
      await scheduleDataSource.deleteEntry(weekday);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheException(
          message: "Couldn't remove this entry",
          originalException: e,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, void>> saveAssignment({
    required String planId,
    required String planName,
    required Set<int> previousWeekdays,
    required Set<int> newWeekdays,
  }) async {
    try {
      await scheduleDataSource.replaceAssignment(
        planId: planId,
        planName: planName,
        removedWeekdays: previousWeekdays.difference(newWeekdays),
        savedWeekdays: newWeekdays,
      );
      return const Right(null);
    } catch (e) {
      return Left(
        CacheException(
          message: "Couldn't save your schedule",
          originalException: e,
        ),
      );
    }
  }
}
