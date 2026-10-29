import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/navigation/home_reload_notifier.dart';
import 'package:forge/core/navigation/schedule_reload_notifier.dart';

/// Registers the reload notifiers the schedule screens read from GetIt.
void registerScheduleReloadNotifiers() {
  unregisterScheduleReloadNotifiers();
  getIt.registerSingleton<ScheduleReloadNotifier>(ScheduleReloadNotifier());
  getIt.registerSingleton<HomeReloadNotifier>(HomeReloadNotifier());
}

void unregisterScheduleReloadNotifiers() {
  if (getIt.isRegistered<ScheduleReloadNotifier>()) {
    getIt.unregister<ScheduleReloadNotifier>();
  }
  if (getIt.isRegistered<HomeReloadNotifier>()) {
    getIt.unregister<HomeReloadNotifier>();
  }
}
