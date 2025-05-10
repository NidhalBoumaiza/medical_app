part of 'rendez_vous_bloc.dart';

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
  List<Object> get props => [rendezVous];
}

class DoctorsLoaded extends RendezVousState {
  final List<MedecinEntity> doctors;

  const DoctorsLoaded(this.doctors);

  @override
  List<Object> get props => [doctors];
}

class RendezVousError extends RendezVousState {
  final String message;

  const RendezVousError(this.message);

  @override
  List<Object> get props => [message];
}

class RendezVousStatusUpdated extends RendezVousState {}

class RendezVousCreated extends RendezVousState {
  final String rendezVousId;
  final String patientName;

  const RendezVousCreated({
    required this.rendezVousId,
    required this.patientName,
  });

  @override
  List<Object> get props => [rendezVousId, patientName];
}

class RendezVousDoctorAssigned extends RendezVousState {}

class PastAppointmentsChecked extends RendezVousState {
  final int updatedCount;
  
  const PastAppointmentsChecked({
    required this.updatedCount,
  });
  
  @override
  List<Object> get props => [updatedCount];
}