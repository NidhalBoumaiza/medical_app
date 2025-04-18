import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/core/utils/map_failure_to_message.dart';
import 'package:medical_app/features/rendez_vous/domain/entities/rendez_vous_entity.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/create_rendez_vous_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/fetch_rendez_vous_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/update_rendez_vous_status_use_case.dart';
import 'package:medical_app/features/rendez_vous/presentation/blocs/rendez-vous%20BLoC/rendez_vous_event.dart';
import 'package:medical_app/features/rendez_vous/presentation/blocs/rendez-vous%20BLoC/rendez_vous_state.dart';


class RendezVousBloc extends Bloc<RendezVousEvent, RendezVousState> {
  final FetchRendezVousUseCase fetchRendezVousUseCase;
  final UpdateRendezVousStatusUseCase updateRendezVousStatusUseCase;
  final CreateRendezVousUseCase createRendezVousUseCase;

  RendezVousBloc({
    required this.fetchRendezVousUseCase,
    required this.updateRendezVousStatusUseCase,
    required this.createRendezVousUseCase,
  }) : super(RendezVousInitial()) {
    on<FetchRendezVous>(_onFetchRendezVous);
    on<UpdateRendezVousStatus>(_onUpdateRendezVousStatus);
    on<CreateRendezVous>(_onCreateRendezVous);
  }

  void _onFetchRendezVous(
      FetchRendezVous event,
      Emitter<RendezVousState> emit,
      ) async {
    emit(RendezVousLoading());
    final failureOrRendezVous = await fetchRendezVousUseCase();
    failureOrRendezVous.fold(
          (failure) => emit(RendezVousError(message: mapFailureToMessage(failure))),
          (rendezVous) => emit(RendezVousLoaded(rendezVous)),
    );
  }

  void _onUpdateRendezVousStatus(
      UpdateRendezVousStatus event,
      Emitter<RendezVousState> emit,
      ) async {
    emit(RendezVousLoading());
    final failureOrUnit =
    await updateRendezVousStatusUseCase(event.rendezVousId, event.status);
    failureOrUnit.fold(
          (failure) => emit(RendezVousError(message: mapFailureToMessage(failure))),
          (_) async {
        // Refetch the updated list after status change
        final failureOrRendezVous = await fetchRendezVousUseCase();
        failureOrRendezVous.fold(
              (failure) =>
              emit(RendezVousError(message: mapFailureToMessage(failure))),
              (rendezVous) => emit(RendezVousLoaded(rendezVous)),
        );
      },
    );
  }

  void _onCreateRendezVous(
      CreateRendezVous event,
      Emitter<RendezVousState> emit,
      ) async {
    emit(RendezVousLoading());
    final failureOrUnit = await createRendezVousUseCase(event.rendezVous);
    failureOrUnit.fold(
          (failure) => emit(RendezVousError(message: mapFailureToMessage(failure))),
          (_) => emit(RendezVousCreated()),
    );
  }
}