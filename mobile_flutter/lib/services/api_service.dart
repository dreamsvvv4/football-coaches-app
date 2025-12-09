import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();

  // URL base del backend.
  // Web: http://localhost:3000
  // Android emulador: http://10.0.2.2:3000
  // Dispositivo físico: http://<tu-ip-local>:3000
  String baseUrl = 'http://localhost:3000';
  final http.Client client = http.Client();

  ApiService._internal();

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, String>> _buildHeaders([Map<String, String>? headers]) async {
    final baseHeaders = {'Content-Type': 'application/json'};
    if (headers != null) baseHeaders.addAll(headers);
    final token = await TokenStorage.instance.readToken();
    if (token != null && token.isNotEmpty) {
      baseHeaders['Authorization'] = 'Bearer $token';
    }
    return baseHeaders;
  }

  Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    final uri = _uri(path);
    final h = await _buildHeaders(headers);
    return client.get(uri, headers: h);
  }

  Future<http.Response> post(String path, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    final uri = _uri(path);
    final h = await _buildHeaders(headers);
    print('POST $uri with body: $body');
    final res = await client.post(uri, headers: h, body: jsonEncode(body));
    print('POST response status: ${res.statusCode}, body: ${res.body}');
    return res;
  }

  Future<http.Response> put(String path, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    final uri = _uri(path);
    final h = await _buildHeaders(headers);
    return client.put(uri, headers: h, body: jsonEncode(body));
  }

  Future<http.Response> delete(String path, {Map<String, String>? headers}) async {
    final uri = _uri(path);
    final h = await _buildHeaders(headers);
    return client.delete(uri, headers: h);
  }
}
