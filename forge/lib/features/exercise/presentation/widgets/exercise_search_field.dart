import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forge/features/exercise/presentation/widgets/exercise_search_bar.dart';

/// Owns the search text controller and debounces keystrokes before they
/// reach [onSearchChanged].
class ExerciseSearchField extends StatefulWidget {
  const ExerciseSearchField({required this.onSearchChanged, super.key});

  static const Duration debounceDuration = Duration(milliseconds: 300);

  final ValueChanged<String> onSearchChanged;

  @override
  State<ExerciseSearchField> createState() => _ExerciseSearchFieldState();
}

class _ExerciseSearchFieldState extends State<ExerciseSearchField> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(ExerciseSearchField.debounceDuration, () {
      if (!mounted) return;
      widget.onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (_, _) => ExerciseSearchBar(
        controller: _controller,
        isActive: _controller.text.isNotEmpty,
        onChanged: _onChanged,
      ),
    );
  }
}
