import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/exceptions.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/core/network/network_info.dart';
import 'package:medical_app/features/rendez_vous/domain/entities/rendez_vous_entity.dart';
import 'package:medical_app/features/rendez_vous/domain/repositories/rendez_vous_repository.dart';

import '../data sources/rdv_local_data_source.dart';
import '../data sources/rdv_remote_data_source.dart';

import '../models/RendezVous.dart';

class RendezVousRepositoryImpl implements RendezVousRepository {
  final RendezVousRemoteDataSource remoteDataSource;
  final RendezVousLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  RendezVousRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<RendezVousEntity>>> getRendezVous({
    String? patientId,
    String? doctorId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final rendezVousModels = await remoteDataSource.getRendezVous(
          patientId: patientId,
          doctorId: doctorId,
        );
        return Right(rendezVousModels);
      } on ServerException {
        return Left(ServerFailure());
      } on ServerMessageException catch (e) {
        return Left(ServerMessageFailure(e.message));
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      try {
        final cachedRendezVous = await localDataSource.getCachedRendezVous();
        return Right(cachedRendezVous);
      } on EmptyCacheException {
        return Left(EmptyCacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Unit>> updateRendezVousStatus(
      String rendezVousId, String status) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateRendezVousStatus(rendezVousId, status);
        return const Right(unit);
      } on ServerException {
        return Left(ServerFailure());
      } on ServerMessageException catch (e) {
        return Left(ServerMessageFailure(e.message));
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> createRendezVous(
      RendezVousEntity rendezVous) async {
    if (await networkInfo.isConnected) {
      try {
        final rendezVousModel = rendezVous is RendezVousModel
            ? rendezVous
            : RendezVousModel(
          id: rendezVous.id,
          patientId: rendezVous.patientId,
          doctorId: rendezVous.doctorId,
          patientName: rendezVous.patientName,
          doctorName: rendezVous.doctorName,
          speciality: rendezVous.speciality,
          startTime: rendezVous.startTime,
          status: rendezVous.status,
        );
        await remoteDataSource.createRendezVous(rendezVousModel);
        return const Right(unit);
      } on ServerException {
        return Left(ServerFailure());
      } on ServerMessageException catch (e) {
        return Left(ServerMessageFailure(e.message));
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }
}