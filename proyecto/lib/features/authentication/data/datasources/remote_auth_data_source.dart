import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RemoteAuthDataSource {
  static const String _baseUrl =
      'https://roble-api.openlab.uninorte.edu.co/auth/proyectoflutter_c35bbd8fbe';

  // Headers comunes para las peticiones
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Maneja las respuestas de error de la API
  String _handleErrorResponse(dynamic errorData, String defaultMessage) {
    debugPrint(
      'Handling error response: $errorData (type: ${errorData.runtimeType})',
    );

    if (errorData is Map<String, dynamic>) {
      // Buscar en diferentes campos de error
      final message =
          errorData['message'] ??
          errorData['error'] ??
          errorData['detail'] ??
          errorData['msg'];

      if (message != null) {
        // Si el mensaje es una lista, tomar el primer elemento
        if (message is List) {
          return message.isNotEmpty ? message[0].toString() : defaultMessage;
        }
        return message.toString();
      }

      // Si hay un campo 'errors' que es una lista
      final errors = errorData['errors'];
      if (errors is List) {
        return errors.isNotEmpty ? errors[0].toString() : defaultMessage;
      }

      return defaultMessage;
    } else if (errorData is List) {
      // Si la respuesta completa es una lista
      if (errorData.isNotEmpty) {
        final firstError = errorData[0];
        if (firstError is Map<String, dynamic>) {
          return _handleErrorResponse(firstError, defaultMessage);
        }
        return firstError.toString();
      }
      return defaultMessage;
    } else if (errorData is String) {
      return errorData;
    }

    debugPrint('Unknown error format: $errorData');
    return defaultMessage;
  }

  /// Realiza el login del usuario
  /// Retorna un Map con los datos del usuario y el token
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      debugPrint('Making login request to: $_baseUrl/login');
      debugPrint('Request body: {"email": "$username", "password": "***"}');

      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: _headers,
        body: jsonEncode({'email': username, 'password': password}),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint('Success response data: $data');
        return {
          'success': true,
          'user': data['user'],
          'token': data['accessToken'] ?? data['token'],
          'refreshToken': data['refreshToken'],
        };
      } else {
        debugPrint('Error response, parsing body...');
        final errorData = jsonDecode(response.body);
        debugPrint('Error data parsed: $errorData');
        final errorMessage = _handleErrorResponse(
          errorData,
          'Error en el login',
        );
        debugPrint('Final error message: $errorMessage');

        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      debugPrint('Exception during login: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Registra un nuevo usuario
  /// Retorna un Map con los datos del usuario y el token
  Future<Map<String, dynamic>> signupDirect({
    required String name,
    required String username,
    required String password,
  }) async {
    try {
      debugPrint('Making signup request to: $_baseUrl/signup-direct');
      debugPrint(
        'Request body: {"name": "$name", "email": "$username", "password": "***"}',
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/signup-direct'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'email': username, // La API espera 'email' en lugar de 'username'
          'password': password,
        }),
      );

      debugPrint('Signup response status: ${response.statusCode}');
      debugPrint('Signup response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'user': data['user'],
          'token': data['accessToken'] ?? data['token'],
          'refreshToken': data['refreshToken'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = _handleErrorResponse(
          errorData,
          'Error en el registro',
        );

        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Cierra la sesión del usuario
  /// Requiere el token de autenticación
  Future<Map<String, dynamic>> logout(String token) async {
    try {
      final headers = {..._headers, 'Authorization': 'Bearer $token'};

      final response = await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Sesión cerrada exitosamente'};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Error al cerrar sesión',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Refresca el token de autenticación
  /// Requiere el refresh token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/refresh-token'),
        headers: _headers,
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'token': data['token'],
          'refreshToken': data['refreshToken'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Error al refrescar token',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Valida si el token actual es válido
  /// Requiere el token de autenticación
  Future<Map<String, dynamic>> validateToken(String token) async {
    try {
      final headers = {..._headers, 'Authorization': 'Bearer $token'};

      final response = await http.get(
        Uri.parse('$_baseUrl/validate-token'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'valid': data['valid'] ?? true,
          'user': data['user'],
        };
      } else {
        return {'success': false, 'valid': false, 'error': 'Token inválido'};
      }
    } catch (e) {
      return {
        'success': false,
        'valid': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  /// Método de prueba para verificar la conexión con la API
  Future<Map<String, dynamic>> testConnection() async {
    try {
      debugPrint('Testing API connection to: $_baseUrl');
      final response = await http.get(
        Uri.parse('$_baseUrl'),
        headers: _headers,
      );

      debugPrint('Test response status: ${response.statusCode}');
      debugPrint('Test response body: ${response.body}');

      return {
        'success': true,
        'status': response.statusCode,
        'body': response.body,
      };
    } catch (e) {
      debugPrint('Test connection error: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Obtiene información del usuario actual
  /// Requiere el token de autenticación
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    try {
      final headers = {..._headers, 'Authorization': 'Bearer $token'};

      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'user': data['user']};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Error al obtener usuario',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
}
