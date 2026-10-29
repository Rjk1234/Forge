import 'package:equatable/equatable.dart';
import 'package:forge/features/personal_bests/domain/entities/personal_best_record.dart';

sealed class PbState extends Equatable {
  const PbState();
}

final class PbInitial extends PbState {
  const PbInitial();

  @override
  List<Object?> get props => [];
}

final class PbLoading extends PbState {
  const PbLoading();

  @override
  List<Object?> get props => [];
}

/// An empty [records] list means no qualifying set exists yet.
final class PbLoaded extends PbState {
  const PbLoaded({required this.records});

  final List<PersonalBestRecord> records;

  @override
  List<Object?> get props => [records];
}

final class PbError extends PbState {
  const PbError();

  @override
  List<Object?> get props => [];
}
