import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/app_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

abstract class BaseApiService {
  static const String baseUrl = AppConstants.baseUrl;

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'Network error: $e');
    }
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'Network error: $e');
    }
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'Network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;

      // Handle the case where the response might be a string-wrapped JSON (common in some PHP APIs)
      // or just standard JSON.
      final decoded = jsonDecode(response.body);

      // If the result is a string that starts with [ or {, it might be double-encoded JSON
      if (decoded is String &&
          (decoded.startsWith('[') || decoded.startsWith('{'))) {
        return jsonDecode(decoded);
      }

      return decoded;
    }
    throw ApiException(
      message: 'Request failed',
      statusCode: response.statusCode,
    );
  }
}
