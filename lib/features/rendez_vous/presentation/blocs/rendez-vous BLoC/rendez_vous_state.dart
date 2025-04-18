import 'package:equatable/equatable.dart';
import 'package:medical_app/features/rendez_vous/domain/entities/rendez_vous_entity.dart';

abstract class RendezVousState extends Equatable {
  const RendezVousState();

  @override
  List<Object?> get props => [];
}

class RendezVousInitial extends RendezVousState {}

class RendezVousLoading extends RendezVousState {}

class RendezVousLoaded extends RendezVousState {
  final List<RendezVousEntity> rendezVous;

  const RendezVousLoaded(this.rendezVous);

  @override
  List<Object?> get props => [rendezVous];
}

class RendezVousCreated extends RendezVousState {}

class RendezVousError extends RendezVousState {
  final String message;

  const RendezVousError({required this.message});

  @override
  List<Object?> get props => [message];
}