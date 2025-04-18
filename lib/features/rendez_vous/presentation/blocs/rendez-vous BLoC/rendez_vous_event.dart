import 'package:equatable/equatable.dart';
import 'package:medical_app/features/rendez_vous/domain/entities/rendez_vous_entity.dart';

abstract class RendezVousEvent extends Equatable {
  const RendezVousEvent();

  @override
  List<Object?> get props => [];
}

class FetchRendezVous extends RendezVousEvent {
  const FetchRendezVous();
}

class UpdateRendezVousStatus extends RendezVousEvent {
  final String rendezVousId;
  final String status;

  const UpdateRendezVousStatus(this.rendezVousId, this.status);

  @override
  List<Object?> get props => [rendezVousId, status];
}

class CreateRendezVous extends RendezVousEvent {
  final RendezVousEntity rendezVous;

  const CreateRendezVous(this.rendezVous);

  @override
  List<Object?> get props => [rendezVous];
}