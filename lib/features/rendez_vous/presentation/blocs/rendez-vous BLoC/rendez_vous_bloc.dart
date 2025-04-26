import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/features/authentication/domain/entities/medecin_entity.dart';
import 'package:medical_app/features/rendez_vous/domain/entities/rendez_vous_entity.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/create_rendez_vous_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/fetch_doctors_by_specialty_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/fetch_rendez_vous_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/update_rendez_vous_status_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/assign_doctor_to_rendez_vous_use_case.dart';

part 'rendez_vous_event.dart';
part 'rendez_vous_state.dart';

class RendezVousBloc extends Bloc<RendezVousEvent, RendezVousState> {
  final FetchRendezVousUseCase fetchRendezVousUseCase;
  final UpdateRendezVousStatusUseCase updateRendezVousStatusUseCase;
  final CreateRendezVousUseCase createRendezVousUseCase;
  final FetchDoctorsBySpecialtyUseCase fetchDoctorsBySpecialtyUseCase;
  final AssignDoctorToRendezVousUseCase assignDoctorToRendezVousUseCase;

  RendezVousBloc({
    required this.fetchRendezVousUseCase,
    required this.updateRendezVousStatusUseCase,
    required this.createRendezVousUseCase,
    required this.fetchDoctorsBySpecialtyUseCase,
    required this.assignDoctorToRendezVousUseCase,
  }) : super(RendezVousInitial()) {
    on<FetchRendezVous>(_onFetchRendezVous);
    on<UpdateRendezVousStatus>(_onUpdateRendezVousStatus);
    on<CreateRendezVous>(_onCreateRendezVous);
    on<FetchDoctorsBySpecialty>(_onFetchDoctorsBySpecialty);
    on<AssignDoctorToRendezVous>(_onAssignDoctorToRendezVous);
  }

  Future<void> _onFetchRendezVous(
      FetchRendezVous event,
      Emitter<RendezVousState> emit,
      ) async {
    emit(RendezVousLoading());
    final failureOrRendezVous = await fetchRendezVousUseCase(
      patientId: event.patientId,
      doctorId: event.doctorId,
    );
    emit(failureOrRendezVous.fold(
          (failure) => RendezVousError(_mapFailureToMessage(failure)),
          (rendezVous) => RendezVousLoaded(rendezVous),
    ));
  }

  Future<void> _onUpdateRendezVousStatus(
      UpdateRendezVousStatus event,
      Emitter<RendezVousState> emit,
      ) async {
    emit(RendezVousLoading());
    final failureOrUnit = await updateRendezVousStatusUseCase(
      rendezVousId: event.rendezVousId,
      status: event.status,
      patientId: event.patientId,
      doctorId: event.doctorId,
      patientName: event.patientName,
      doctorName: event.doctorName,
    );
    emit(failureOrUnit.fold(
          (failure) => RendezVousError(_mapFailureToMessage(failure)),
          (_) => RendezVousStatusUpdated(),
    ));
  }

  Future<void> _onCreateRendezVous(
      CreateRendezVous event,
      Emitter<RendezVousState> emit,
      ) async {
    emit(RendezVousLoading());
    final failureOrUnit = await createRendezVousUseCase(event.rendezVous);
    emit(failureOrUnit.fold(
          (failure) => RendezVousError(_mapFailureToMessage(failure)),
          (_) => RendezVousCreated(
        rendezVousId: event.rendezVous.id ?? '',
        patientName: event.rendezVous.patientName ?? '',
      ),
    ));
  }

  Future<void> _onFetchDoctorsBySpecialty(
      FetchDoctorsBySpecialty event,
      Emitter<RendezVousState> emit,
      ) async {
    emit(RendezVousLoading());
    final failureOrDoctors = await fetchDoctorsBySpecialtyUseCase(
      event.specialty,
      event.startTime,
    );
    emit(failureOrDoctors.fold(
          (failure) => RendezVousError(_mapFailureToMessage(failure)),
          (doctors) => DoctorsLoaded(doctors),
    ));
  }

  Future<void> _onAssignDoctorToRendezVous(
      AssignDoctorToRendezVous event,
      Emitter<RendezVousState> emit,
      ) async {
    emit(RendezVousLoading());
    final failureOrUnit = await assignDoctorToRendezVousUseCase(
      event.rendezVousId,
      event.doctorId,
      event.doctorName,
    );
    emit(failureOrUnit.fold(
          (failure) => RendezVousError(_mapFailureToMessage(failure)),
          (_) => RendezVousDoctorAssigned(),
    ));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Une erreur serveur s\'est produite';
      case ServerMessageFailure:
        final message = (failure as ServerMessageFailure).message;
        return message == 'Rendezvous not found'
            ? 'Consultation non trouvée'
            : message;
      case OfflineFailure:
        return 'Pas de connexion internet';
      case EmptyCacheFailure:
        return 'Aucune donnée en cache disponible';
      default:
        return 'Une erreur inattendue s\'est produite';
    }
  }
}