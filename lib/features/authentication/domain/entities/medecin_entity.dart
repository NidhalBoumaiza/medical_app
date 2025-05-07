import 'package:medical_app/features/authentication/domain/entities/user_entity.dart';

class MedecinEntity extends UserEntity {
  final String? speciality;
  final String? numLicence;

  MedecinEntity({
    String? id,
    required String name,
    required String lastName,
    required String email,
    required String role,
    required String gender,
    required String phoneNumber,
    DateTime? dateOfBirth,
    this.speciality,
    this.numLicence = '',
    bool? accountStatus,
    int? verificationCode,
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

  factory MedecinEntity.create({
    String? id,
    required String name,
    required String lastName,
    required String email,
    required String role,
    required String gender,
    required String phoneNumber,
    DateTime? dateOfBirth,
    String? speciality,
    String? numLicence = '',
    bool? accountStatus,
    int? verificationCode,
    DateTime? validationCodeExpiresAt,
  }) {
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

  @override
  List<Object?> get props => [
    ...super.props,
    speciality,
    numLicence,
  ];
}