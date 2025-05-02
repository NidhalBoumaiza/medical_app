import '../../domain/entities/medecin_entity.dart';
import './user_model.dart';

class MedecinModel extends UserModel {
  final String speciality;
  final String numLicence;

  MedecinModel({
    String? id,
    required String name,
    required String lastName,
    required String email,
    required String role,
    required String gender,
    required String phoneNumber,
    DateTime? dateOfBirth,
    bool? accountStatus,
    int? verificationCode,
    required this.speciality,
    required this.numLicence,
    DateTime? validationCodeExpiresAt,
  }) : super(
    id: id,
    name: name,
    lastName: lastName,
    email: email,
    role: role,
    gender: gender,
    phoneNumber: phoneNumber,
    dateOfBirth: dateOfBirth,
    accountStatus: accountStatus,
    verificationCode: verificationCode,
    validationCodeExpiresAt: validationCodeExpiresAt,
  );

  factory MedecinModel.fromJson(Map<String, dynamic> json) {
    return MedecinModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      gender: json['gender'] as String,
      phoneNumber: json['phoneNumber'] as String,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      speciality: json['speciality'] as String,
      numLicence: json['numLicence'] as String,
      accountStatus: json['accountStatus'] as bool?,
      verificationCode: json['verificationCode'] as int?,
      validationCodeExpiresAt: json['validationCodeExpiresAt'] != null
          ? DateTime.parse(json['validationCodeExpiresAt'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['speciality'] = speciality;
    data['numLicence'] = numLicence;

    return data;
  }

  MedecinEntity toEntity() {
    return MedecinEntity(
      id: id,
      name: name,
      lastName: lastName,
      email: email,
      role: role,
      gender: gender,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      speciality: speciality,
      numLicence: numLicence,
      accountStatus: accountStatus,
      verificationCode: verificationCode,
      validationCodeExpiresAt: validationCodeExpiresAt,
    );
  }
}