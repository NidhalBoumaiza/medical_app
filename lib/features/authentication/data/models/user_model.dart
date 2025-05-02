import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
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
    DateTime? validationCodeExpiresAt
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
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
      accountStatus: json['accountStatus'] as bool?,
      verificationCode: json['verificationCode'] as int?,
      validationCodeExpiresAt: json['validationCodeExpiresAt'] != null
          ? DateTime.parse(json['validationCodeExpiresAt'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'lastName': lastName,
      'email': email,
      'role': role,
      'gender': gender,
      'phoneNumber': phoneNumber,
    };
    if (id != null) {
      data['id'] = id;
    }
    if (dateOfBirth != null) {
      data['dateOfBirth'] = dateOfBirth!.toIso8601String();
    }
    if (accountStatus != null) {
      data['accountStatus'] = accountStatus;
    }
    if (verificationCode != null) {
      data['verificationCode'] = verificationCode;
    }
    if (validationCodeExpiresAt != null) {
      data['validationCodeExpiresAt'] = validationCodeExpiresAt!.toIso8601String();
    }
    return data;
  }
}