import 'package:flutter/foundation.dart';

/// Singleton notifier that signals the WorkoutPlansScreen to re-read the database.
///
/// AppShell calls [notify] whenever the user switches to the Plans tab
/// (branch index 1). WorkoutPlansScreen subscribes in initState and
/// dispatches WorkoutPlansLoadRequested to its Bloc on each notification,
/// enabling the optimistic re-read without re-entering the skeleton state.
class WorkoutPlansReloadNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
