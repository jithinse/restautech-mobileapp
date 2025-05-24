class TimeoutException implements Exception {
  final String message;

  TimeoutException(this.message);

  @override
  String toString() => message;
}

class NoInternetException implements Exception {
  final String message;

  NoInternetException(this.message);

  @override
  String toString() => message;
}

class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  @override
  String toString() => message;
}

class InvalidFormatException implements Exception {
  final String message;

  InvalidFormatException(this.message);

  @override
  String toString() => message;
}

class UnknownException implements Exception {
  final String message;

  UnknownException(this.message);

  @override
  String toString() => message;
}