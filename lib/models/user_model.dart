class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'admin' or 'staff'
  final String? phoneNumber;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'admin',
    this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'admin',
      phoneNumber: map['phoneNumber'],
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? role,
    String? phoneNumber,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
