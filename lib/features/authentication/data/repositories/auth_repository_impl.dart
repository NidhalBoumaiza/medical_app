import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/exceptions.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/core/network/network_info.dart';
import 'package:medical_app/features/authentication/data/models/medecin_model.dart';
import 'package:medical_app/features/authentication/data/models/patient_model.dart';
import 'package:medical_app/features/authentication/data/models/user_model.dart';
import 'package:medical_app/features/authentication/domain/entities/medecin_entity.dart';
import 'package:medical_app/features/authentication/domain/entities/patient_entity.dart';
import 'package:medical_app/features/authentication/domain/entities/user_entity.dart';
import 'package:medical_app/features/authentication/domain/repositories/auth_repository.dart';

import '../data sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<void> signInWithGoogle() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.signInWithGoogle();
      } on AuthException catch (e) {
        throw AuthFailure(e.message);
      } on ServerException catch (e) {
        throw ServerFailure();
      }
    } else {
      throw OfflineFailure();
    }
  }

  @override
  Future<Either<Failure, Unit>> createAccount({
    required UserEntity user,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        UserModel userModel;
        if (user is PatientEntity) {
          userModel = PatientModel(
            id: user.id,
            name: user.name,
            lastName: user.lastName,
            email: user.email,
            role: user.role,
            gender: user.gender,
            phoneNumber: user.phoneNumber,
            dateOfBirth: user.dateOfBirth,
            antecedent: user.antecedent,
          );
        } else if (user is MedecinEntity) {
          userModel = MedecinModel(
            id: user.id,
            name: user.name,
            lastName: user.lastName,
            email: user.email,
            role: user.role,
            gender: user.gender,
            phoneNumber: user.phoneNumber,
            dateOfBirth: user.dateOfBirth,
            speciality: user.speciality,
            numLicence: user.numLicence,
          );
        } else {
          userModel = UserModel(
            id: user.id ?? "",
            name: user.name,
            lastName: user.lastName,
            email: user.email,
            role: user.role,
            gender: user.gender,
            phoneNumber: user.phoneNumber,
            dateOfBirth: user.dateOfBirth,
          );
        }
        await remoteDataSource.createAccount(userModel, password);
        return const Right(unit);
      } on ServerException {
        return Left(ServerFailure());
      } on ServerMessageException catch (e) {
        return Left(ServerMessageFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.login(email, password);
        UserEntity userEntity;
        if (userModel is PatientModel) {
          userEntity = PatientEntity(
            id: userModel.id,
            name: userModel.name,
            lastName: userModel.lastName,
            email: userModel.email,
            role: userModel.role,
            gender: userModel.gender,
            phoneNumber: userModel.phoneNumber,
            dateOfBirth: userModel.dateOfBirth,
            antecedent: userModel.antecedent,
          );
        } else if (userModel is MedecinModel) {
          userEntity = MedecinEntity(
            id: userModel.id,
            name: userModel.name,
            lastName: userModel.lastName,
            email: userModel.email,
            role: userModel.role,
            gender: userModel.gender,
            phoneNumber: userModel.phoneNumber,
            dateOfBirth: userModel.dateOfBirth,
            speciality: userModel.speciality,
            numLicence: userModel.numLicence,
          );
        } else {
          userEntity = UserEntity(
            id: userModel.id,
            name: userModel.name,
            lastName: userModel.lastName,
            email: userModel.email,
            role: userModel.role,
            gender: userModel.gender,
            phoneNumber: userModel.phoneNumber,
            dateOfBirth: userModel.dateOfBirth,
          );
        }
        return Right(userEntity);
      } on ServerException {
        return Left(ServerFailure());
      } on ServerMessageException catch (e) {
        return Left(ServerMessageFailure(e.message));
      } on UnauthorizedException {
        return Left(UnauthorizedFailure());
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateUser(UserEntity user) async {
    if (await networkInfo.isConnected) {
      try {
        UserModel userModel;
        if (user is PatientEntity) {
          userModel = PatientModel(
            id: user.id!,
            name: user.name,
            lastName: user.lastName,
            email: user.email,
            role: user.role,
            gender: user.gender,
            phoneNumber: user.phoneNumber,
            dateOfBirth: user.dateOfBirth,
            antecedent: user.antecedent,
          );
        } else if (user is MedecinEntity) {
          userModel = MedecinModel(
            id: user.id!,
            name: user.name,
            lastName: user.lastName,
            email: user.email,
            role: user.role,
            gender: user.gender,
            phoneNumber: user.phoneNumber,
            dateOfBirth: user.dateOfBirth,
            speciality: user.speciality,
            numLicence: user.numLicence,
          );
        } else {
          userModel = UserModel(
            id: user.id!,
            name: user.name,
            lastName: user.lastName,
            email: user.email,
            role: user.role,
            gender: user.gender,
            phoneNumber: user.phoneNumber,
            dateOfBirth: user.dateOfBirth,
          );
        }
        await remoteDataSource.updateUser(userModel);
        return const Right(unit);
      } on ServerException {
        return Left(ServerFailure());
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      }
    } else {
      return Left(OfflineFailure());
    }
  }
}