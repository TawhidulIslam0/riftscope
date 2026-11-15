import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? status;
  const ApiException(this.message, [this.status]);
  @override
  String toString() => message;
}

class ApiClient {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  Future<dynamic> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 22));
      final dynamic body = response.body.isEmpty ? {} : jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) return body;
      final message = body is Map ? (body['error'] ?? body['message'] ?? 'Request failed') : 'Request failed';
      throw ApiException(message.toString(), response.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Could not reach RiftScope backend. Check that the backend is running and API_BASE_URL is correct. ($e)');
    }
  }

  Future<Map<String, dynamic>> getMap(String path) async {
    final result = await get(path);
    if (result is Map<String, dynamic>) return result;
    throw const ApiException('Unexpected response from server.');
  }

  Future<List<dynamic>> getList(String path) async {
    final result = await get(path);
    if (result is List) return result;
    throw const ApiException('Unexpected list response from server.');
  }
}
