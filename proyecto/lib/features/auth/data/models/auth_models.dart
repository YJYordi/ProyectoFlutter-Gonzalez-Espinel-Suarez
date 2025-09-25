import 'package:proyecto/Domain/Entities/user.dart';

class UserModel extends UserEntity {
  final String accessToken;
  final String refreshToken;

  UserModel({
    required super.name,
    required super.email,
    required super.username,
    required super.password,
    required super.role,
    required super.createdAt,
    required this.accessToken,
    required this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      username: json["username"] ?? "",
      password: json["password"] ?? "",
      role: json["role"] ?? "",
      createdAt: json["createdAt"] ?? "",
      accessToken: json["accessToken"] ?? "",
      refreshToken: json["refreshToken"] ?? "",
    );
  }
}