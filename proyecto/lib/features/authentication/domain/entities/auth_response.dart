class AuthResponse {
  final bool success;
  final String? token;
  final String? refreshToken;
  final Map<String, dynamic>? user;
  final String? error;
  final String? message;

  const AuthResponse({
    required this.success,
    this.token,
    this.refreshToken,
    this.user,
    this.error,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      token: json['token'],
      refreshToken: json['refreshToken'],
      user: json['user'],
      error: json['error'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'token': token,
      'refreshToken': refreshToken,
      'user': user,
      'error': error,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'AuthResponse(success: $success, token: $token, refreshToken: $refreshToken, user: $user, error: $error, message: $message)';
  }
}
