import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/prescription_entity.dart';
import '../../domain/usecases/create_prescription_use_case.dart';
import '../../domain/usecases/edit_prescription_use_case.dart';
import '../../domain/usecases/get_doctor_prescriptions_use_case.dart';
import '../../domain/usecases/get_patient_prescriptions_use_case.dart';
import '../../domain/usecases/get_prescription_by_appointment_id_use_case.dart';
import '../../domain/usecases/get_prescription_by_id_use_case.dart';

part 'prescription_event.dart';
part 'prescription_state.dart';

class PrescriptionBloc extends Bloc<PrescriptionEvent, PrescriptionState> {
  final CreatePrescriptionUseCase createPrescriptionUseCase;
  final EditPrescriptionUseCase editPrescriptionUseCase;
  final GetPatientPrescriptionsUseCase getPatientPrescriptionsUseCase;
  final GetDoctorPrescriptionsUseCase getDoctorPrescriptionsUseCase;
  final GetPrescriptionByIdUseCase getPrescriptionByIdUseCase;
  final GetPrescriptionByAppointmentIdUseCase getPrescriptionByAppointmentIdUseCase;

  PrescriptionBloc({
    required this.createPrescriptionUseCase,
    required this.editPrescriptionUseCase,
    required this.getPatientPrescriptionsUseCase,
    required this.getDoctorPrescriptionsUseCase,
    required this.getPrescriptionByIdUseCase,
    required this.getPrescriptionByAppointmentIdUseCase,
  }) : super(PrescriptionInitial()) {
    on<CreatePrescription>(_onCreatePrescription);
    on<EditPrescription>(_onEditPrescription);
    on<GetPatientPrescriptions>(_onGetPatientPrescriptions);
    on<GetDoctorPrescriptions>(_onGetDoctorPrescriptions);
    on<GetPrescriptionById>(_onGetPrescriptionById);
    on<GetPrescriptionByAppointmentId>(_onGetPrescriptionByAppointmentId);
  }

  Future<void> _onCreatePrescription(
    CreatePrescription event,
    Emitter<PrescriptionState> emit,
  ) async {
    emit(PrescriptionLoading());
    
    // Generate ID for prescription
    final prescriptionId = const Uuid().v4();
    
    final prescription = PrescriptionEntity.create(
      id: prescriptionId,
      appointmentId: event.appointmentId,
      patientId: event.patientId,
      patientName: event.patientName,
      doctorId: event.doctorId,
      doctorName: event.doctorName,
      medications: event.medications,
      note: event.note,
    );
    
    final result = await createPrescriptionUseCase(
      prescription: prescription,
    );
    
    result.fold(
      (failure) => emit(PrescriptionError(message: failure.message)),
      (prescription) => emit(PrescriptionCreated(prescription: prescription)),
    );
  }

  Future<void> _onEditPrescription(
    EditPrescription event,
    Emitter<PrescriptionState> emit,
  ) async {
    emit(PrescriptionLoading());
    
    final result = await editPrescriptionUseCase(
      prescription: event.prescription,
    );
    
    result.fold(
      (failure) => emit(PrescriptionError(message: failure.message)),
      (prescription) => emit(PrescriptionEdited(prescription: prescription)),
    );
  }

  Future<void> _onGetPatientPrescriptions(
    GetPatientPrescriptions event,
    Emitter<PrescriptionState> emit,
  ) async {
    emit(PrescriptionLoading());
    
    final result = await getPatientPrescriptionsUseCase(
      patientId: event.patientId,
    );
    
    result.fold(
      (failure) => emit(PrescriptionError(message: failure.message)),
      (prescriptions) => emit(PatientPrescriptionsLoaded(prescriptions: prescriptions)),
    );
  }

  Future<void> _onGetDoctorPrescriptions(
    GetDoctorPrescriptions event,
    Emitter<PrescriptionState> emit,
  ) async {
    emit(PrescriptionLoading());
    
    final result = await getDoctorPrescriptionsUseCase(
      doctorId: event.doctorId,
    );
    
    result.fold(
      (failure) => emit(PrescriptionError(message: failure.message)),
      (prescriptions) => emit(DoctorPrescriptionsLoaded(prescriptions: prescriptions)),
    );
  }

  Future<void> _onGetPrescriptionById(
    GetPrescriptionById event,
    Emitter<PrescriptionState> emit,
  ) async {
    emit(PrescriptionLoading());
    
    final result = await getPrescriptionByIdUseCase(
      prescriptionId: event.prescriptionId,
    );
    
    result.fold(
      (failure) => emit(PrescriptionError(message: failure.message)),
      (prescription) => emit(PrescriptionLoaded(prescription: prescription)),
    );
  }

  Future<void> _onGetPrescriptionByAppointmentId(
    GetPrescriptionByAppointmentId event,
    Emitter<PrescriptionState> emit,
  ) async {
    emit(PrescriptionLoading());
    
    final result = await getPrescriptionByAppointmentIdUseCase(
      appointmentId: event.appointmentId,
    );
    
    result.fold(
      (failure) => emit(PrescriptionError(message: failure.message)),
      (prescription) => prescription != null 
          ? emit(PrescriptionLoaded(prescription: prescription))
          : emit(PrescriptionNotFound()),
    );
  }
} 