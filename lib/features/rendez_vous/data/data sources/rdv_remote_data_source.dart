import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/core/error/exceptions.dart';
import 'package:medical_app/features/rendez_vous/data/data%20sources/rdv_local_data_source.dart';
import 'package:medical_app/features/authentication/domain/entities/medecin_entity.dart';
import 'package:medical_app/features/authentication/data/models/medecin_model.dart';
import '../models/RendezVous.dart';

abstract class RendezVousRemoteDataSource {
  Future<List<RendezVousModel>> getRendezVous({
    String? patientId,
    String? doctorId,
  });

  Future<void> updateRendezVousStatus(String rendezVousId, String status);

  Future<void> createRendezVous(RendezVousModel rendezVous);

  Future<List<MedecinEntity>> getDoctorsBySpecialty(
      String specialty,
      DateTime startTime,
      );

  Future<void> assignDoctorToRendezVous(
      String rendezVousId,
      String doctorId,
      String doctorName,
      );
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
      }
      if (doctorId != null) {
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
    } on FirebaseException catch (e) {
      throw ServerException('Firestore error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<MedecinEntity>> getDoctorsBySpecialty(
      String specialty,
      DateTime startTime,
      ) async {
    try {
      // Get doctors with the specified specialty
      final doctorSnapshot = await firestore
          .collection('medecins')
          .where('speciality', isEqualTo: specialty)
          .get();
      final doctors = doctorSnapshot.docs
          .map((doc) => MedecinModel.fromJson(doc.data()).toEntity())
          .toList();

      // Filter out doctors with conflicting rendezvous
      final availableDoctors = <MedecinEntity>[];
      for (final doctor in doctors) {
        final rendezVousSnapshot = await firestore
            .collection('rendez_vous')
            .where('doctorId', isEqualTo: doctor.id)
            .where('startTime', isEqualTo: startTime.toIso8601String())
            .where('status', isEqualTo: 'Accepté')
            .get();
        if (rendezVousSnapshot.docs.isEmpty) {
          availableDoctors.add(doctor);
        }
      }
      return availableDoctors;
    } on FirebaseException catch (e) {
      throw ServerException('Firestore error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> assignDoctorToRendezVous(
      String rendezVousId,
      String doctorId,
      String doctorName,
      ) async {
    try {
      await firestore
          .collection('rendez_vous')
          .doc(rendezVousId)
          .update({
        'doctorId': doctorId,
        'doctorName': doctorName,
        'status': 'En attente',
      });
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw ServerMessageException('Rendezvous not found');
      }
      throw ServerException('Firestore error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}