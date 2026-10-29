import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/navigation/home_reload_notifier.dart';
import 'package:forge/core/navigation/progress_reload_notifier.dart';
import 'package:forge/core/navigation/stats_reload_notifier.dart';
import 'package:forge/core/navigation/workout_data_refresher.dart';
import 'package:forge/core/navigation/workout_history_reload_notifier.dart';

void main() {
  test('refresh notifies stats, progress, history and home listeners', () {
    final stats = StatsReloadNotifier();
    final progress = ProgressReloadNotifier();
    final history = WorkoutHistoryReloadNotifier();
    final home = HomeReloadNotifier();
    final notified = <String>[];
    stats.addListener(() => notified.add('stats'));
    progress.addListener(() => notified.add('progress'));
    history.addListener(() => notified.add('history'));
    home.addListener(() => notified.add('home'));

    WorkoutDataRefresher(
      stats: stats,
      progress: progress,
      history: history,
      home: home,
    ).refresh();

    expect(notified, unorderedEquals(['stats', 'progress', 'history', 'home']));
  });
}
