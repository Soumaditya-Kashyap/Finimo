import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic errorBody;

  ApiException({
    required this.statusCode,
    required this.message,
    this.errorBody,
  });

  @override
  String toString() => 'ApiException [$statusCode]: $message';
}

/// Central HTTP Client with automatic Bearer token injection and JSON serialization
class ApiClient {
  final TokenStorage tokenStorage;
  final http.Client _httpClient;

  ApiClient({
    TokenStorage? tokenStorage,
    http.Client? httpClient,
  })  : tokenStorage = tokenStorage ?? TokenStorage(),
        _httpClient = httpClient ?? http.Client();

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '${ApiConfig.baseUrl}$cleanPath';
    final uri = Uri.parse(fullUrl);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      final cleanParams = queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      return uri.replace(queryParameters: cleanParams);
    }
    return uri;
  }

  Future<Map<String, String>> _headers({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = await _headers(requiresAuth: requiresAuth);

    final response = await _httpClient
        .get(uri, headers: headers)
        .timeout(ApiConfig.connectTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = await _headers(requiresAuth: requiresAuth);

    final response = await _httpClient
        .post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.connectTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> put(
    String path, {
    dynamic body,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path);
    final headers = await _headers(requiresAuth: requiresAuth);

    final response = await _httpClient
        .put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.connectTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> patch(
    String path, {
    dynamic body,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path);
    final headers = await _headers(requiresAuth: requiresAuth);

    final response = await _httpClient
        .patch(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.connectTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> delete(
    String path, {
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path);
    final headers = await _headers(requiresAuth: requiresAuth);

    final response = await _httpClient
        .delete(uri, headers: headers)
        .timeout(ApiConfig.connectTimeout);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = response.body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    String errorMessage = 'Request failed with status: ${response.statusCode}';
    if (body is Map && body.containsKey('detail')) {
      errorMessage = body['detail'].toString();
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: errorMessage,
      errorBody: body,
    );
  }
}
