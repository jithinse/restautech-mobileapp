import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

class NetworkLogger {
  static void logRequest({
    required Uri url,
    required String method,
    Map<String, String>? headers,
    dynamic body,
  }) {
    debugPrint('┌─────────────────────── Request ───────────────────────');
    debugPrint('│ $method $url');
    debugPrint('├─────────────────────── Headers ───────────────────────');
    headers?.forEach((key, value) => debugPrint('│ $key: $value'));
    debugPrint('├──────────────────────── Body ─────────────────────────');

    try {
      if (body != null) {
        final formattedBody = JsonEncoder.withIndent('  ').convert(body);
        formattedBody.split('\n').forEach((line) => debugPrint('│ $line'));
      }
    } catch (e) {
      debugPrint('│ $body');
    }

    debugPrint('└──────────────────────────────────────────────────────');
  }

  static void logResponse(http.Response response) {
    debugPrint('┌────────────────────── Response ───────────────────────');
    debugPrint('│ Status: ${response.statusCode}');
    debugPrint('│ URL: ${response.request?.url}');
    debugPrint('├────────────────────── Headers ───────────────────────');
    response.headers.forEach((key, value) => debugPrint('│ $key: $value'));
    debugPrint('├─────────────────────── Body ─────────────────────────');

    try {
      if (response.body.isNotEmpty) {
        if (response.headers['content-type']?.contains('application/json') == true) {
          final formattedBody = JsonEncoder.withIndent('  ').convert(json.decode(response.body));
          formattedBody.split('\n').forEach((line) => debugPrint('│ $line'));
        } else {
          debugPrint('│ [Non-JSON Response] ${response.body}');
        }
      } else {
        debugPrint('│ [Empty response body]');
      }
    } catch (e) {
      debugPrint('│ [Error parsing response] ${response.body}');
    }

    debugPrint('└──────────────────────────────────────────────────────');
  }

  static void logRedirect(String location) {
    debugPrint('┌────────────────────── Redirect ───────────────────────');
    debugPrint('│ Redirecting to: $location');
    debugPrint('└──────────────────────────────────────────────────────');
  }

  static void logSuccess(String message, [dynamic data]) {
    debugPrint('┌────────────────────── Success ───────────────────────');
    debugPrint('│ $message');
    if (data != null) {
      debugPrint('├──────────────────────── Data ─────────────────────────');
      try {
        final formattedData = JsonEncoder.withIndent('  ').convert(data);
        formattedData.split('\n').forEach((line) => debugPrint('│ $line'));
      } catch (e) {
        debugPrint('│ $data');
      }
    }
    debugPrint('└──────────────────────────────────────────────────────');
  }

  static void logWarning(String message, [dynamic details]) {
    debugPrint('┌────────────────────── Warning ───────────────────────');
    debugPrint('│ $message');
    if (details != null) {
      debugPrint('├────────────────────── Details ───────────────────────');
      debugPrint('│ $details');
    }
    debugPrint('└──────────────────────────────────────────────────────');
  }

  static void logError(dynamic error, StackTrace stackTrace) {
    debugPrint('┌─────────────────────── Error ────────────────────────');
    debugPrint('│ $error');
    debugPrint('├──────────────────── StackTrace ─────────────────────');
    stackTrace.toString().split('\n').take(5).forEach((line) => debugPrint('│ $line'));
    debugPrint('└──────────────────────────────────────────────────────');
  }
}