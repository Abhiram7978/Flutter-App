/// Exception hierarchy for API errors.
///
/// Mirrors the backend's error_code values from app/core/exceptions.py
/// so the UI can react to specific failure types (e.g. show a distinct
/// message for STOCK_NOT_FOUND vs a generic network failure).
sealed class ApiException implements Exception {
  const ApiException(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  @override
  String toString() => 'ApiException: $message (code: $errorCode)';
}

/// No network connection, DNS failure, or connection refused.
final class NetworkException extends ApiException {
  const NetworkException([
    super.message = 'Could not reach the server. Check your connection.',
  ]);
}

/// Request timed out.
final class TimeoutException extends ApiException {
  const TimeoutException([super.message = 'The request timed out.']);
}

/// 401 — missing or invalid X-API-Key.
final class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    super.message = 'Authentication failed. Check the API key.',
  ]) : super(errorCode: 'UNAUTHORIZED');
}

/// 404 — resource not found (e.g. unknown ticker).
final class NotFoundException extends ApiException {
  const NotFoundException([
    super.message = 'The requested resource was not found.',
    super.errorCode,
  ]);
}

/// 400/422 — invalid request (bad date range, invalid ticker format, etc).
final class ValidationException extends ApiException {
  const ValidationException(super.message, {super.errorCode});
}

/// 503 — backend dependency (DB/Redis/provider) unavailable.
final class ServiceUnavailableException extends ApiException {
  const ServiceUnavailableException([
    super.message = 'The service is temporarily unavailable. Try again shortly.',
  ]) : super(errorCode: 'SERVICE_UNAVAILABLE');
}

/// Anything else — 500s, unparseable responses, etc.
final class UnknownApiException extends ApiException {
  const UnknownApiException([
    super.message = 'Something went wrong. Please try again.',
  ]);
}
