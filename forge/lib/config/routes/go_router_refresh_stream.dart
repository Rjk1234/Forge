import 'dart:async';

import 'package:flutter/foundation.dart';

/// Wraps a [Stream] as a [Listenable] so go_router's [refreshListenable]
/// can re-evaluate the redirect callback whenever the stream emits.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
