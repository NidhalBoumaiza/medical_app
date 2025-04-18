import 'package:medical_app/features/rendez_vous/data/data%20sources/rdv_local_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/core/error/exceptions.dart';

import '../models/RendezVous.dart';

abstract class RendezVousRemoteDataSource {
  /// Fetches the list of consultations from the remote data source.
  Future<List<RendezVousModel>> getRendezVous( {
    String? patientId,
    String? doctorId,
  });

  /// Updates the status of a consultation identified by [rendezVousId] to [status].
  Future<void> updateRendezVousStatus(String rendezVousId, String status);

  /// Creates a new consultation with the provided [rendezVous].
  Future<void> createRendezVous(RendezVousModel rendezVous);
}


class RendezVousRemoteDataSourceImpl implements RendezVousRemoteDataSource {
  final FirebaseFirestore firestore;
  final RendezVousLocalDataSource localDataSource;

  RendezVousRemoteDataSourceImpl({
    required this.firestore,
    required this.localDataSource,
  });

  @override
  Future<List<RendezVousModel>> getRendezVous({
    String? patientId,
    String? doctorId,
  }) async {
    if (patientId == null && doctorId == null) {
      throw ServerException('Either patientId or doctorId must be provided');
    }
    try {
      Query<Map<String, dynamic>> query =
      firestore.collection('rendez_vous');
      if (patientId != null) {
        query = query.where('patientId', isEqualTo: patientId);
      } else if (doctorId != null) {
        query = query.where('doctorId', isEqualTo: doctorId);
      }
      final snapshot = await query.get();
      final rendezVous = snapshot.docs
          .map((doc) => RendezVousModel.fromJson(doc.data()))
          .toList();
      await localDataSource.cacheRendezVous(rendezVous);
      return rendezVous;
    } on FirebaseException catch (e) {
      throw ServerException('Firestore error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> updateRendezVousStatus(String rendezVousId, String status) async {
    try {
      await firestore
          .collection('rendez_vous')
          .doc(rendezVousId)
          .update({'status': status});
      // Note: No cache update here; UI will refetch via BLoC
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw ServerMessageException('Rendezvous not found');
      }
      throw ServerException('Firestore error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> createRendezVous(RendezVousModel rendezVous) async {
    try {
      final docRef = firestore.collection('rendez_vous').doc();
      final rendezVousWithId = RendezVousModel(
        id: docRef.id,
        patientId: rendezVous.patientId,
        doctorId: rendezVous.doctorId,
        patientName: rendezVous.patientName,
        doctorName: rendezVous.doctorName,
        speciality: rendezVous.speciality,
        startTime: rendezVous.startTime,
        status: rendezVous.status,
      );
      await docRef.set(rendezVousWithId.toJson());
      // Note: No cache update here; UI will refetch via BLoC
    } on FirebaseException catch (e) {
      throw ServerException('Firestore error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}