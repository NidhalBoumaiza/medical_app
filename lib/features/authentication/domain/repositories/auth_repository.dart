import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/features/authentication/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> signInWithGoogle();
  Future<Either<Failure, Unit>> createAccount({
    required UserEntity user,
    required String password,
  });
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });
  Future<Either<Failure, Unit>> updateUser(UserEntity user);
}