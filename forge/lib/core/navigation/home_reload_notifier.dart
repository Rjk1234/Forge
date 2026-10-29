import 'package:flutter/foundation.dart';

/// Singleton notifier that signals the Home screen to reload.
///
/// Home stays mounted between tab visits, so it relies on this signal to
/// show a workout, plan or schedule that changed elsewhere.
class HomeReloadNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
