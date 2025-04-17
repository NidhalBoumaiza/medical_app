import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/failures.dart';

import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Signs in the user using Google authentication.
  Future<void> signInWithGoogle();

  /// Creates a new user account with the provided [user] entity and [password].
  Future<Either<Failure, Unit>> createAccount({
    required UserEntity user,
    required String password,
  });

  /// Logs in a user with the provided [email] and [password].
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });
}