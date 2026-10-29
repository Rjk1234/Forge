import 'package:equatable/equatable.dart';

class PickerContext extends Equatable {
  const PickerContext({required this.planName});

  final String planName;

  @override
  List<Object> get props => [planName];
}
