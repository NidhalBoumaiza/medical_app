part of 'rendez_vous_bloc.dart';

abstract class RendezVousEvent extends Equatable {
  const RendezVousEvent();

  @override
  List<Object?> get props => [];
}

class FetchRendezVous extends RendezVousEvent {
  final String? patientId;
  final String? doctorId;

  const FetchRendezVous({this.patientId, this.doctorId});

  @override
  List<Object?> get props => [patientId, doctorId];
}

class UpdateRendezVousStatus extends RendezVousEvent {
  final String rendezVousId;
  final String status;

  const UpdateRendezVousStatus(this.rendezVousId, this.status);

  @override
  List<Object> get props => [rendezVousId, status];
}

class CreateRendezVous extends RendezVousEvent {
  final RendezVousEntity rendezVous;

  const CreateRendezVous(this.rendezVous);

  @override
  List<Object> get props => [rendezVous];
}

class FetchDoctorsBySpecialty extends RendezVousEvent {
  final String specialty;
  final DateTime startTime;

  const FetchDoctorsBySpecialty(this.specialty, this.startTime);

  @override
  List<Object> get props => [specialty, startTime];
}

class AssignDoctorToRendezVous extends RendezVousEvent {
  final String rendezVousId;
  final String doctorId;
  final String doctorName;

  const AssignDoctorToRendezVous(
      this.rendezVousId,
      this.doctorId,
      this.doctorName,
      );

  @override
  List<Object> get props => [rendezVousId, doctorId, doctorName];
}