import 'package:flutter/material.dart';

/// Observes the Plans tab navigator so [RouteRevealListener] can tell when a
/// screen pushed from the Plans screen is popped and Plans is visible again.
final RouteObserver<ModalRoute<void>> plansRouteObserver =
    RouteObserver<ModalRoute<void>>();
