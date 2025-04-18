import 'package:medical_app/features/rendez_vous/domain/entities/rendez_vous_entity.dart';

class RendezVousModel extends RendezVousEntity {
  RendezVousModel({
    String? id,
    String? patientId,
    String? doctorId,
    String? patientName,
    String? doctorName,
    String? speciality,
    required DateTime startTime,
    required String status,
  }) : super(
    id: id,
    patientId: patientId,
    doctorId: doctorId,
    patientName: patientName,
    doctorName: doctorName,
    speciality: speciality,
    startTime: startTime,
    status: status,
  );

  factory RendezVousModel.fromJson(Map<String, dynamic> json) {
    return RendezVousModel(
      id: json['id'] as String?,
      patientId: json['patientId'] as String?,
      doctorId: json['doctorId'] as String?,
      patientName: json['patientName'] as String?,
      doctorName: json['doctorName'] as String?,
      speciality: json['speciality'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'startTime': startTime.toIso8601String(),
      'status': status,
    };
    if (id != null) data['id'] = id;
    if (patientId != null) data['patientId'] = patientId;
    if (doctorId != null) data['doctorId'] = doctorId;
    if (patientName != null) data['patientName'] = patientName;
    if (doctorName != null) data['doctorName'] = doctorName;
    if (speciality != null) data['speciality'] = speciality;
    return data;
  }
}