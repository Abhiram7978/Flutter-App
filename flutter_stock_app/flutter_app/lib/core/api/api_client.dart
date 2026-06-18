import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_exception.dart';

/// Thin wrapper around [Dio] that:
///  - Injects the X-API-Key header on every request.
///  - Maps Dio/HTTP errors to the app's [ApiException] hierarchy so the
///    rest of the app never has to know about Dio or HTTP status codes.
class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? _buildDio();

  final Dio _dio;

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: const {ApiConfig.apiKeyHeader: ApiConfig.apiKey},
      ),
    );
    return dio;
  }

  /// GET request returning the raw decoded JSON body.
  ///
  /// Throws a typed [ApiException] subclass on any failure — callers
  /// should not need to catch [DioException] directly.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return response.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST request returning the raw decoded JSON body.
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: body,
      );
      return response.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  ApiException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _mapStatusCode(e);

      case DioExceptionType.cancel:
        return const UnknownApiException('Request was cancelled.');

      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const NetworkException();
    }
  }

  ApiException _mapStatusCode(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final errorCode = (data is Map) ? data['error'] as String? : null;
    final message = (data is Map) ? data['message'] as String? : null;

    switch (statusCode) {
      case 400:
      case 422:
        return ValidationException(
          message ?? 'Invalid request.',
          errorCode: errorCode,
        );
      case 401:
        return const UnauthorizedException();
      case 404:
        return NotFoundException(
          message ?? 'Not found.',
          errorCode,
        );
      case 503:
        return const ServiceUnavailableException();
      default:
        return UnknownApiException(message ?? 'Unexpected error ($statusCode).');
    }
  }
}
