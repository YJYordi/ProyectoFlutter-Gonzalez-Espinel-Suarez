import 'package:http/http.dart' as http;

class ApiError {
  final String message;
  final int? statusCode;
  final String? details;

  const ApiError({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => message;
}

class ErrorService {
  static ApiError handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return const ApiError(
          message: 'Solicitud incorrecta. Verifica los datos enviados.',
          statusCode: 400,
        );
      case 401:
        return const ApiError(
          message: 'No autorizado. Inicia sesión nuevamente.',
          statusCode: 401,
        );
      case 403:
        return const ApiError(
          message: 'Acceso denegado. No tienes permisos para esta acción.',
          statusCode: 403,
        );
      case 404:
        return const ApiError(
          message: 'Recurso no encontrado.',
          statusCode: 404,
        );
      case 409:
        return const ApiError(
          message: 'Conflicto. El recurso ya existe o está en uso.',
          statusCode: 409,
        );
      case 422:
        return const ApiError(
          message: 'Datos inválidos. Verifica la información enviada.',
          statusCode: 422,
        );
      case 500:
        return const ApiError(
          message: 'Error interno del servidor. Intenta más tarde.',
          statusCode: 500,
        );
      case 502:
        return const ApiError(
          message: 'Servidor no disponible. Intenta más tarde.',
          statusCode: 502,
        );
      case 503:
        return const ApiError(
          message: 'Servicio temporalmente no disponible.',
          statusCode: 503,
        );
      default:
        return ApiError(
          message: 'Error inesperado (${response.statusCode}). Intenta más tarde.',
          statusCode: response.statusCode,
        );
    }
  }

  static ApiError handleNetworkError(Exception e) {
    if (e.toString().contains('SocketException') || 
        e.toString().contains('HandshakeException')) {
      return const ApiError(
        message: 'Sin conexión a internet. Verifica tu conexión.',
      );
    } else if (e.toString().contains('TimeoutException')) {
      return const ApiError(
        message: 'Tiempo de espera agotado. Intenta nuevamente.',
      );
    } else {
      return ApiError(
        message: 'Error de conexión: ${e.toString()}',
      );
    }
  }

  static ApiError handleGenericError(dynamic error) {
    if (error is ApiError) {
      return error;
    } else if (error is Exception) {
      return handleNetworkError(error);
    } else {
      return ApiError(
        message: 'Error inesperado: ${error.toString()}',
      );
    }
  }
}
