import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({required String username, required String password})
    : super(username: username, password: password);

  Map<String, dynamic> toJson() => {'username': username, 'password': password};

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(username: json['username'], password: json['password']);
  }
}
