class UserModel {
  final String id; // Unique identifier
  final String? phoneNumber;
  final String? email;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String? profileImagePath;
  final String role; // student, parent, school admin/owner, other
  final String? schoolId;

  UserModel({
    required this.id,
    this.phoneNumber,
    this.email,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.profileImagePath,
    required this.role,
    this.schoolId,
  });

  // Create a copy of the user with updated fields
  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? gender,
    String? profileImagePath,
    String? role,
    String? schoolId,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      role: role ?? this.role,
      schoolId: schoolId ?? this.schoolId,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'profileImagePath': profileImagePath,
      'role': role,
      'schoolId': schoolId,
    };
  }

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      profileImagePath: json['profileImagePath'],
      role: json['role'],
      schoolId: json['schoolId'],
    );
  }

  // Check if profile is complete
  bool get isProfileComplete {
    return firstName.isNotEmpty && 
           lastName.isNotEmpty && 
           gender.isNotEmpty && 
           role.isNotEmpty;
  }

  // Get full name
  String get fullName => '$firstName $lastName';
}
