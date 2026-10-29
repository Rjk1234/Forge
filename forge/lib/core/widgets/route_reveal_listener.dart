import 'package:flutter/material.dart';

/// Calls [onRevealed] each time the screen is shown again because the route
/// above it was popped. [observer] must be attached to the enclosing navigator.
class RouteRevealListener extends StatefulWidget {
  const RouteRevealListener({
    required this.observer,
    required this.onRevealed,
    required this.child,
    super.key,
  });

  final RouteObserver<ModalRoute<void>> observer;
  final VoidCallback onRevealed;
  final Widget child;

  @override
  State<RouteRevealListener> createState() => _RouteRevealListenerState();
}

class _RouteRevealListenerState extends State<RouteRevealListener>
    with RouteAware {
  ModalRoute<void>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route == _route) return;
    widget.observer.unsubscribe(this);
    _route = route;
    if (route != null) widget.observer.subscribe(this, route);
  }

  @override
  void didPopNext() => widget.onRevealed();

  @override
  void dispose() {
    widget.observer.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
