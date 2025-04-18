import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/features/rendez_vous/domain/entities/rendez_vous_entity.dart';

abstract class RendezVousRepository {
  /// Fetches the list of consultations for the current doctor.
  Future<Either<Failure, List<RendezVousEntity>>> getRendezVous();

  /// Updates the status of a consultation identified by [rendezVousId] to [status].
  Future<Either<Failure, Unit>> updateRendezVousStatus(String rendezVousId, String status);

  /// Creates a new consultation with the provided [rendezVous] entity.
  Future<Either<Failure, Unit>> createRendezVous(RendezVousEntity rendezVous);
}