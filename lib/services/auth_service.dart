<<<<<<< HEAD




=======
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../config/api_config.dart';

<<<<<<< HEAD

import '../config/constants.dart';
import '../services/token_storage.dart';
import '../utilis/network_logger.dart';
import 'api_service.dart';
=======
import '../config/constant.dart';
import '../services/token_storage.dart';
import '../utilis/network_logger.dart';
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5






class AuthService {





  Future<Map<String, dynamic>> login(String email, String password) async {
    final client = http.Client();
    try {
      var url = '${ApiConfig.baseUrl}login';
      NetworkLogger.logRequest(
        url: Uri.parse(url),
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.authKey}',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
<<<<<<< HEAD
        body: {'email': email, 'password': password, 'role': 'Counter'}, // Add role here
=======
        body: {'email': email, 'password': password, 'role': 'Kitchen'}, // Add role here
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
      );

      var response = await _attemptLogin(client, url, email, password);
      NetworkLogger.logResponse(response);

      if (response.statusCode == 302) {
        url = '${ApiConfig.baseUrl}api/v1/login';
        NetworkLogger.logRedirect(response.headers['location'] ?? 'Unknown location');

        NetworkLogger.logRequest(
          url: Uri.parse(url),
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${ApiConfig.authKey}',
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
<<<<<<< HEAD
          body: {'email': email, 'password': password, 'role': 'Counter'}, // Add role here
=======
          body: {'email': email, 'password': password, 'role': 'Kitchen'}, // Add role here
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
        );

        response = await _attemptLogin(client, url, email, password);
        NetworkLogger.logResponse(response);
      }

      return _parseResponse(response);
    } catch (e, stackTrace) {
      NetworkLogger.logError(e, stackTrace);
      rethrow;
    } finally {
      client.close();
    }
  }
  Future<void> logout() async {
    await TokenStorage.clear();
  }




  Future<http.Response> _attemptLogin(http.Client client, String url, String email, String password) async {
    return await client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiConfig.authKey}',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
<<<<<<< HEAD
        'role': 'Counter', // Explicitly send kitchen role
=======
        'role': 'Kitchen', // Explicitly send kitchen role
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
      }),
    ).timeout(AppConstants.apiTimeout);
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    final responseBody = utf8.decode(response.bodyBytes);

    try {
      final data = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        // Log successful response data for debugging
        NetworkLogger.logSuccess('Login successful', data);
        return data;
      }
      else if (response.statusCode == 422) {
        throw CredentialsException(
          data['message'] ?? 'Invalid credentials',
          data['errors'] ?? {},
        );
      }
      else {
        throw HttpException(
            data['message'] ?? 'Request failed with status ${response.statusCode}'
        );
      }
    } catch (e) {
      // Check if this is already our custom exception
      if (e is CredentialsException) rethrow;
      if (e is FormatException) {
        // If JSON parsing fails, include the raw response body in the error
        NetworkLogger.logError(
            FormatException('JSON Parse Error: ${e.toString()}\nRaw response: $responseBody'),
            StackTrace.current
        );
        throw FormatException('Failed to parse response: ${e.toString()}');
      }
      throw e;  // Rethrow other exceptions
    }
  }



}

class CredentialsException implements Exception {
  final String message;
  final Map<String, dynamic> errors;

  CredentialsException(this.message, this.errors);

  @override
  String toString() => 'CredentialsException: $message';
}
