import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/features/authentication/domain/entities/user_entity.dart';
import 'package:medical_app/features/authentication/domain/usecases/create_account_use_case.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final CreateAccountUseCase createAccountUseCase;

  SignupBloc({required this.createAccountUseCase}) : super(SignupInitial()) {
    on<SignupWithUserEntity>(_onSignupWithUserEntity);
  }

  void _onSignupWithUserEntity(
      SignupWithUserEntity event,
      Emitter<SignupState> emit,
      ) async {
    emit(SignupLoading());
    final failureOrUnit = await createAccountUseCase(event.user, event.password);
    failureOrUnit.fold(
          (failure) => emit(SignupError(message: _mapFailureToMessage(failure))),
          (_) => emit(SignupSuccess()),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again later.';
      case OfflineFailure:
        return 'No internet connection. Please check your network.';
      case AuthFailure:
        return (failure as AuthFailure).message;
      case ServerMessageFailure:
        return (failure as ServerMessageFailure).message;
      default:
        return 'Unexpected error occurred.';
    }
  }
}