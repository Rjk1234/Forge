import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/home/domain/entities/planned_exercise.dart';
import 'package:forge/features/home/domain/entities/week_day_status.dart';
import 'package:forge/features/home/domain/rules/daily_content.dart';
import 'package:forge/features/home/domain/rules/planned_workout_math.dart';
import 'package:forge/features/home/domain/rules/week_overview.dart';

void main() {
  group('planned workout math', () {
    const bench = PlannedExercise(
      name: 'Bench',
      type: ExerciseType.weighted,
      sets: 3,
      restSec: 60,
      repetitions: 10,
      weightKg: 62.5,
    );
    const pushUp = PlannedExercise(
      name: 'Push-Up',
      type: ExerciseType.bodyweight,
      sets: 3,
      restSec: 30,
      repetitions: 15,
    );

    test('volume counts weighted exercises only', () {
      expect(plannedVolumeKg([bench, pushUp]), 1875);
    });

    test('set count adds every exercise', () {
      expect(plannedSetCount([bench, pushUp]), 6);
    });

    test('time rounds up and uses the target duration for timed sets', () {
      const plank = PlannedExercise(
        name: 'Plank',
        type: ExerciseType.timeBased,
        sets: 1,
        restSec: 1,
        durationSec: 60,
      );
      expect(estimatedWorkoutMinutes([plank]), 2);
      expect(estimatedWorkoutMinutes(const []), 0);
    });
  });

  group('week overview', () {
    const push = WeekPlanRef(planId: 'p1', planName: 'Push');
    const done = WeekSessionRef(sessionId: 's1', planName: 'Push', count: 1);

    test(
      'completed wins, past scheduled days are missed, today is flagged',
      () {
        final days = buildWeekDays(
          today: DateTime(2026, 10, 14),
          planned: {1: push, 2: push, 3: push, 5: push},
          completed: {1: done},
        );

        expect(days, hasLength(7));
        expect(days[0].state, WeekDayState.completed);
        expect(days[1].state, WeekDayState.missed);
        expect(days[2].state, WeekDayState.planned);
        expect(days[3].state, WeekDayState.rest);
        expect(days[4].state, WeekDayState.planned);
        expect(days.where((d) => d.isToday).single.weekday, 3);
        expect(days[0].session, done);
        expect(days[2].plan, push);
      },
    );

    test('a workout on an unscheduled day still counts as completed', () {
      final days = buildWeekDays(
        today: DateTime(2026, 10, 14),
        planned: const {},
        completed: {2: done},
      );
      expect(days[1].state, WeekDayState.completed);
    });

    test('progress counts finished scheduled days', () {
      final days = buildWeekDays(
        today: DateTime(2026, 10, 14),
        planned: {1: push, 2: push, 5: push},
        completed: {1: done, 4: done},
      );
      expect(weekProgress(days), (done: 1, total: 3));
    });

    test('next workout wraps from Sunday to Monday', () {
      final next = findNextWorkout(
        todayWeekday: DateTime.sunday,
        planNameByWeekday: {DateTime.monday: 'Push'},
      );
      expect(next!.weekday, DateTime.monday);
    });

    test('a plan only on today is not the next workout', () {
      expect(
        findNextWorkout(
          todayWeekday: DateTime.wednesday,
          planNameByWeekday: {DateTime.wednesday: 'Push'},
        ),
        isNull,
      );
    });
  });

  group('daily content', () {
    test('the index is stable within a day and cycles through the list', () {
      final a = dailyIndex(DateTime(2026, 3, 1, 8), 8);
      expect(dailyIndex(DateTime(2026, 3, 1, 22), 8), a);
      expect(dailyIndex(DateTime(2026, 3, 2), 8), (a + 1) % 8);
    });
  });
}
