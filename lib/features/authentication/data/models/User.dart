class User {
  String id;
  String name;
  String lastName;
  String email;
  String role;
  String gender;
  String phoneNumber;
  DateTime? dateOfBirth;


  User({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.role,
    required this.gender,
    required this.phoneNumber,
    required this.dateOfBirth
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'name': name,
      'lastName': lastName,
      'email': email,
      'role': role,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,

    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      lastName: json['lastName'],
      email: json['email'],
      role: json['role'],
      gender: json['gender'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'],
    );
  }


}