import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/features/authentication/domain/entities/user_entity.dart';

import '../../../domain/usecases/login_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;

  LoginBloc({required this.loginUseCase}) : super(LoginInitial()) {
    on<LoginWithEmailAndPassword>(_onLoginWithEmailAndPassword);
    on<LoginWithGoogle>(_onLoginWithGoogle);
  }

  void _onLoginWithEmailAndPassword(
      LoginWithEmailAndPassword event,
      Emitter<LoginState> emit,
      ) async {
    emit(LoginLoading());
    final failureOrUser = await loginUseCase(
      email: event.email,
      password: event.password,
    );
    failureOrUser.fold(
          (failure) => emit(LoginError(message: _mapFailureToMessage(failure))),
          (user) => emit(LoginSuccess(user: user)),
    );
  }

  void _onLoginWithGoogle(
      LoginWithGoogle event,
      Emitter<LoginState> emit,
      ) async {
    emit(LoginLoading());
    try {
      await loginUseCase.authRepository.signInWithGoogle();
      emit(LoginSuccess(user: UserEntity(
        id: '',
        name: '',
        lastName: '',
        email: '',
        role: 'patient',
        gender: '',
        phoneNumber: '',
        dateOfBirth: null,
      ))); // Simplified, as Google sign-in may not return full user data immediately
    } catch (e) {
      emit(LoginError(message: e.toString()));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again later.';
      case OfflineFailure:
        return 'No internet connection. Please check your network.';
      case UnauthorizedFailure:
        return 'Invalid email or password.';
      case AuthFailure:
        return (failure as AuthFailure).message;
      case ServerMessageFailure:
        return (failure as ServerMessageFailure).message;
      default:
        return 'Unexpected error occurred.';
    }
  }
}