import 'package:proyecto/Domain/Entities/user.dart';

class UserModel extends UserEntity {
  final String accessToken;
  final String refreshToken;

  UserModel({
    required super.username,
    required super.name,
    required super.email,
    required super.password,
    required super.role,
    required super.createdAt,
    required this.accessToken,
    required this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json["username"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      password: json["password"] ?? "",
      role: UserRole.values.firstWhere(
        (e) => e.name == json["role"],
        orElse: () => UserRole.student,
      ),
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      accessToken: json["accessToken"] ?? "",
      refreshToken: json["refreshToken"] ?? "",
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'name': name,
      'email': email,
      'password': password,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
