// lib/services/admin_auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminAuthResult {
  final String token;
  final String role;
  final int adminId;
  final int? divisionId;

  AdminAuthResult({
    required this.token,
    required this.role,
    required this.adminId,
    this.divisionId,
  });

  factory AdminAuthResult.fromJson(Map<String, dynamic> json) {
    return AdminAuthResult(
      token: json['token'] as String,
      role: json['role'] as String,
      adminId: (json['adminId'] as num).toInt(),
      divisionId: json['divisionId'] == null
          ? null
          : (json['divisionId'] as num).toInt(),
    );
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AdminAuthService {
  final String baseUrl;
  final http.Client _client;

  AdminAuthService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  Future<AdminAuthResult> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/api/admin/auth/login');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'passwordHash': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return AdminAuthResult.fromJson(data);
    } else if (response.statusCode == 401) {
      try {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        throw AuthException(err['error']?.toString() ?? 'Invalid credentials');
      } catch (_) {
        throw AuthException('Invalid credentials');
      }
    } else {
      throw AuthException('Server error (${response.statusCode})');
    }
  }
}
