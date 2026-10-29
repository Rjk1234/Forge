import 'package:flutter/material.dart';

/// Owns the repeating animation that drives [ShimmerBox] placeholders.
///
/// Skeleton widgets stay stateless: they build their placeholders inside
/// [builder] and pass the given animation to each `ShimmerBox`.
class ShimmerAnimation extends StatefulWidget {
  const ShimmerAnimation({
    required this.builder,
    this.period = const Duration(milliseconds: 1400),
    super.key,
  });

  final Widget Function(BuildContext context, Animation<double> animation)
  builder;
  final Duration period;

  @override
  State<ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}
