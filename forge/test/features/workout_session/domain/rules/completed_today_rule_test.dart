import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/workout_session/domain/rules/completed_today_rule.dart';

import '../../../../helpers/session_builders.dart';

void main() {
  final today = DateTime(2026, 10, 23, 12);

  bool done(List sessions, {String planId = 'p1'}) => hasCompletedWorkoutOn(
    sessions: List.of(sessions.cast()),
    planId: planId,
    day: today,
  );

  test('the same plan completed earlier today is done', () {
    expect(
      done([sessionOf(planId: 'p1', startedAt: DateTime(2026, 10, 23, 7))]),
      isTrue,
    );
  });

  test('a different plan done today does not count', () {
    expect(
      done([sessionOf(planId: 'p2', startedAt: DateTime(2026, 10, 23, 7))]),
      isFalse,
    );
  });

  test('the same plan done yesterday does not count', () {
    expect(
      done([sessionOf(planId: 'p1', startedAt: DateTime(2026, 10, 22, 18))]),
      isFalse,
    );
  });

  test('a workout begun before midnight counts for the day it began', () {
    final lateNight = sessionOf(
      planId: 'p1',
      startedAt: DateTime(2026, 10, 22, 23, 50),
    );
    expect(done([lateNight]), isFalse);
    expect(
      hasCompletedWorkoutOn(
        sessions: [lateNight],
        planId: 'p1',
        day: DateTime(2026, 10, 22, 23, 55),
      ),
      isTrue,
    );
  });

  test('a session with every set skipped is not done', () {
    expect(
      done([
        sessionOf(
          planId: 'p1',
          startedAt: DateTime(2026, 10, 23, 7),
          allSkipped: true,
        ),
      ]),
      isFalse,
    );
  });

  test('no sessions (none yet, or the only one was deleted) is not done', () {
    expect(done(const []), isFalse);
  });
}
