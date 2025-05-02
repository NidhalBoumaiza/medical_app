import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? id; // id is optional
  final String name;
  final String lastName;
  final String email;
  final String role;
  final String gender;
  final String phoneNumber;
  final DateTime? dateOfBirth;
  final bool? accountStatus; // accountStatus is optional
  final int? verificationCode; // verificationCode is optional
  final DateTime? validationCodeExpiresAt; // validationCodeExpiresAt is optional

  UserEntity({
    this.id, // id is not required
    required this.name,
    required this.lastName,
    required this.email,
    required this.role,
    required this.gender,
    required this.phoneNumber,
    this.dateOfBirth,
    this.accountStatus, // accountStatus is not required
    this.verificationCode, // verificationCode is not required
    this.validationCodeExpiresAt, // validationCodeExpiresAt is not required
  });

  factory UserEntity.create({
    String? id, // id is optional
    required String name,
    required String lastName,
    required String email,
    required String role,
    required String gender,
    required String phoneNumber,
    DateTime? dateOfBirth,
    bool? accountStatus, // accountStatus is optional
    int? verificationCode,
    DateTime? validationCodeExpiresAt, // validationCodeExpiresAt is optional
  }) {
    return UserEntity(
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
  }

  @override
  List<Object?> get props => [
    id,
    name,
    lastName,
    email,
    role,
    gender,
    phoneNumber,
    dateOfBirth,
    accountStatus,
    verificationCode,
    validationCodeExpiresAt,
  ];
}