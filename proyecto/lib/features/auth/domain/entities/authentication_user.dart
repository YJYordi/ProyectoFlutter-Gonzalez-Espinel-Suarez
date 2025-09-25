class AuthenticationUser {
  final String username;
  final String password;

  AuthenticationUser({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }

  factory AuthenticationUser.fromJson(Map<String, dynamic> json) {
    return AuthenticationUser(
      username: json['username'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
