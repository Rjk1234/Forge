import 'package:flutter/foundation.dart';

/// Singleton notifier that signals the Weekly Schedule screen to reload.
///
/// The Schedule tab stays mounted between visits, so it relies on this signal
/// to show assignments saved or removed on other screens (for example the
/// Schedule button on Create Plan or Plan Detail).
class ScheduleReloadNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
