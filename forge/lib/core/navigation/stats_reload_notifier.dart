import 'package:flutter/foundation.dart';

/// Singleton notifier that signals the StatsScreen to recalculate.
///
/// AppShell calls [notify] whenever the user switches to the Stats tab. The
/// tab stays mounted between visits, so this is the only signal that a
/// session may have been saved since the last calculation.
class StatsReloadNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
