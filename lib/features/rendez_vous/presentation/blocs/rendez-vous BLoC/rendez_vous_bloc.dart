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
import 'package:cloud_firestore/cloud_firestore.dart';

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
    on<CheckAndUpdatePastAppointments>(_onCheckAndUpdatePastAppointments);
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

  Future<void> _onCheckAndUpdatePastAppointments(
    CheckAndUpdatePastAppointments event,
    Emitter<RendezVousState> emit,
  ) async {
    print('Starting CheckAndUpdatePastAppointments for user: ${event.userId}, role: ${event.userRole}');
    try {
      // Get current time
      final now = DateTime.now();
      print('Current time: ${now.toString()}');
      
      // Reference to Firestore
      final firestore = FirebaseFirestore.instance;
      
      // Create a query based on the user's role
      Query query;
      if (event.userRole == 'medecin') {
        query = firestore.collection('rendez_vous')
            .where('doctorId', isEqualTo: event.userId)
            .where('status', isEqualTo: 'accepted');
      } else {
        query = firestore.collection('rendez_vous')
            .where('patientId', isEqualTo: event.userId)
            .where('status', isEqualTo: 'accepted');
      }
      
      // Execute the query
      final querySnapshot = await query.get();
      print('Found ${querySnapshot.docs.length} accepted appointments');
      
      // Process each document
      int updatedCount = 0;
      for (var doc in querySnapshot.docs) {
        // Parse the appointment start time
        final data = doc.data() as Map<String, dynamic>;
        DateTime startTime;
        if (data['startTime'] is Timestamp) {
          startTime = (data['startTime'] as Timestamp).toDate();
        } else {
          startTime = DateTime.parse(data['startTime'] as String);
        }
        
        print('Appointment ${doc.id}: startTime=${startTime.toString()}, isBefore=${startTime.isBefore(now)}');
        
        // If the appointment has passed, update it to completed
        if (startTime.isBefore(now)) {
          // Get additional data for notification
          final patientId = data['patientId'] as String?;
          final patientName = data['patientName'] as String?;
          final doctorId = data['doctorId'] as String?;
          final doctorName = data['doctorName'] as String?;
          
          if (patientId != null && patientName != null && 
              doctorId != null && doctorName != null) {
            
            print('Updating appointment ${doc.id} to completed');
            
            // Update status to completed
            try {
              await firestore.collection('rendez_vous').doc(doc.id).update({
                'status': 'completed',
              });
              updatedCount++;
            } catch (updateError) {
              print('Error updating appointment ${doc.id}: $updateError');
            }
          }
        }
      }
      
      print('Updated $updatedCount appointments to completed');
      
      // Emit state to indicate updates are complete
      emit(PastAppointmentsChecked(updatedCount: updatedCount));
      
      // After processing all appointments, fetch updated list
      if (updatedCount > 0) {
        print('Fetching updated appointments for ${event.userRole}');
        if (event.userRole == 'medecin') {
          add(FetchRendezVous(doctorId: event.userId));
        } else {
          add(FetchRendezVous(patientId: event.userId));
        }
      }
      
    } catch (e) {
      print('Error checking past appointments: $e');
      // We don't emit an error state here to avoid interrupting the user experience
      // but we log the error for debugging purposes
    }
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