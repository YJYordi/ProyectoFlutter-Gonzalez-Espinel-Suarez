enum UserRole { student, teacher }

class UserEntity {
  final String username;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final DateTime createdAt;

  const UserEntity({
    required this.username, 
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'name': name,
      'email': email,
      'password': password,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      username: json['username'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}


