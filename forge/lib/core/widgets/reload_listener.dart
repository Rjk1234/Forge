import 'package:flutter/material.dart';

/// Calls [onReload] whenever [notifier] fires, for tabs that stay mounted
/// (IndexedStack) and therefore cannot reload from a lifecycle callback.
class ReloadListener extends StatefulWidget {
  const ReloadListener({
    required this.notifier,
    required this.onReload,
    required this.child,
    super.key,
  });

  final ChangeNotifier notifier;
  final VoidCallback onReload;
  final Widget child;

  @override
  State<ReloadListener> createState() => _ReloadListenerState();
}

class _ReloadListenerState extends State<ReloadListener> {
  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(widget.onReload);
  }

  @override
  void didUpdateWidget(ReloadListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier == widget.notifier &&
        oldWidget.onReload == widget.onReload) {
      return;
    }
    oldWidget.notifier.removeListener(oldWidget.onReload);
    widget.notifier.addListener(widget.onReload);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(widget.onReload);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
