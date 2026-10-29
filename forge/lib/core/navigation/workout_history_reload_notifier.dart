import 'package:flutter/foundation.dart';

/// Singleton notifier that signals the WorkoutHistoryScreen to re-read the database.
///
/// AppShell calls [notify] whenever the user switches to the History tab.
/// The tab stays mounted between visits, so this is the only signal that a
/// session may have been saved since the last read.
class WorkoutHistoryReloadNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
