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

/// Central HTTP Client with automatic Bearer token injection,
/// automatic 401 token refresh interceptor, and JSON serialization.
class ApiClient {
  final TokenStorage tokenStorage;
  final http.Client _httpClient;

  // Single in-flight token refresh future to deduplicate concurrent requests
  Future<bool>? _refreshFuture;

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

  Future<dynamic> _sendRequest(
    String method,
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path, queryParameters);
    var headers = await _headers(requiresAuth: requiresAuth);

    http.Response response;
    try {
      response = await _executeRaw(method, uri, headers, body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Network connection failed: $e',
      );
    }

    // Auto-refresh token if 401 Unauthorized and not already calling refresh
    if (response.statusCode == 401 &&
        requiresAuth &&
        !path.contains(ApiConfig.refreshToken)) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry the request once with freshly rotated access token
        headers = await _headers(requiresAuth: true);
        try {
          response = await _executeRaw(method, uri, headers, body);
        } catch (e) {
          if (e is ApiException) rethrow;
          throw ApiException(
            statusCode: 0,
            message: 'Network retry failed: $e',
          );
        }
      }
    }

    return _handleResponse(response);
  }

  Future<http.Response> _executeRaw(
    String method,
    Uri uri,
    Map<String, String> headers,
    dynamic body,
  ) {
    final encodedBody = body != null ? jsonEncode(body) : null;
    switch (method.toUpperCase()) {
      case 'GET':
        return _httpClient
            .get(uri, headers: headers)
            .timeout(ApiConfig.connectTimeout);
      case 'POST':
        return _httpClient
            .post(uri, headers: headers, body: encodedBody)
            .timeout(ApiConfig.connectTimeout);
      case 'PUT':
        return _httpClient
            .put(uri, headers: headers, body: encodedBody)
            .timeout(ApiConfig.connectTimeout);
      case 'PATCH':
        return _httpClient
            .patch(uri, headers: headers, body: encodedBody)
            .timeout(ApiConfig.connectTimeout);
      case 'DELETE':
        return _httpClient
            .delete(uri, headers: headers)
            .timeout(ApiConfig.connectTimeout);
      default:
        throw ApiException(
            statusCode: 400, message: 'Unsupported method: $method');
    }
  }

  Future<bool> _refreshToken() async {
    if (_refreshFuture != null) {
      return await _refreshFuture!;
    }
    _refreshFuture = _executeRefresh();
    try {
      return await _refreshFuture!;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<bool> _executeRefresh() async {
    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final uri = _buildUri(ApiConfig.refreshToken);
      final response = await _httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refresh_token': refreshToken}),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('access_token')) {
          final newAccess = data['access_token'] as String;
          final newRefresh =
              (data['refresh_token'] as String?) ?? refreshToken;

          await tokenStorage.saveTokens(
            accessToken: newAccess,
            refreshToken: newRefresh,
          );

          if (data.containsKey('family') && data['family'] is Map) {
            final fam = data['family'] as Map<String, dynamic>;
            if (fam['id'] != null) {
              await tokenStorage.saveActiveFamilyId(fam['id'].toString());
            }
            if (fam['family_name'] != null || fam['name'] != null) {
              await tokenStorage.saveActiveFamilyName(
                (fam['family_name'] ?? fam['name']).toString(),
              );
            }
          }
          return true;
        }
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 422) {
        // Refresh token itself is revoked or permanently invalid
        await tokenStorage.clearAll();
        return false;
      }
    } catch (_) {
      // Temporary network hitch or timeout: DO NOT clear tokens!
      return false;
    }
    return false;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) =>
      _sendRequest('GET', path,
          queryParameters: queryParameters, requiresAuth: requiresAuth);

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) =>
      _sendRequest('POST', path,
          body: body,
          queryParameters: queryParameters,
          requiresAuth: requiresAuth);

  Future<dynamic> put(
    String path, {
    dynamic body,
    bool requiresAuth = true,
  }) =>
      _sendRequest('PUT', path, body: body, requiresAuth: requiresAuth);

  Future<dynamic> patch(
    String path, {
    dynamic body,
    bool requiresAuth = true,
  }) =>
      _sendRequest('PATCH', path, body: body, requiresAuth: requiresAuth);

  Future<dynamic> delete(
    String path, {
    bool requiresAuth = true,
  }) =>
      _sendRequest('DELETE', path, requiresAuth: requiresAuth);

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
      final detail = body['detail'];
      if (detail is String) {
        errorMessage = detail;
      } else if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first.containsKey('msg')) {
          errorMessage = first['msg'].toString();
        }
      }
    } else if (body is Map && body.containsKey('message')) {
      errorMessage = body['message'].toString();
    } else if (body is Map && body.containsKey('error')) {
      final error = body['error'];
      if (error is Map && error.containsKey('message')) {
        errorMessage = error['message'].toString();
      } else if (error is String) {
        errorMessage = error;
      }
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: errorMessage,
      errorBody: body,
    );
  }
}
