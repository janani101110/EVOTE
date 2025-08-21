import 'dart:convert';
import 'package:evote/models/admin.dart';
import 'package:http/http.dart' as http;



class AdminManagementService {
  final http.Client _client;
  final String baseUrl;
  
  
  AdminManagementService({http.Client? client, required this.baseUrl})
      : _client = client ?? http.Client();
        

  Uri _u(String p) => Uri.parse('$baseUrl$p');

  Future<List<AdminUserDto>> list({required String token}) async {
    final res = await _client.get(
      _u('/api/admin/super/admins'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final arr = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
      return arr.map(AdminUserDto.fromJson).toList();
    }
    if (res.statusCode == 401) {
      throw ApiException('Unauthorized. Please login again.', status: 401);
    }
    if (res.statusCode == 403) {
      throw ApiException('Forbidden. SUPER_ADMIN only.', status: 403);
    }
    throw ApiException('Server error (${res.statusCode}).', status: res.statusCode);
  }

  Future<AdminUserDto> create({
    required String token,
    required String fullName,
    required String email,
    required String password,
    required String role,
    int? divisionId,
  }) async {
    final body = {
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role,
      'divisionId': divisionId,
    };

    final res = await _client.post(
      _u('/api/admin/super/admins'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return AdminUserDto.fromJson(json);
    }
    if (res.statusCode == 401) {
      throw ApiException('Unauthorized. Please login again.', status: 401);
    }
    if (res.statusCode == 403) {
      throw ApiException('Forbidden. SUPER_ADMIN only.', status: 403);
    }
    throw ApiException('Failed to create admin (${res.statusCode}).',
        status: res.statusCode);
  }

  Future<void> deactivate({
    required String token,
    required int id,
  }) async {
    final res = await _client.delete(
      _u('/api/admin/super/admins/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200 || res.statusCode == 204) return;
    if (res.statusCode == 401) {
      throw ApiException('Unauthorized. Please login again.', status: 401);
    }
    if (res.statusCode == 403) {
      throw ApiException('Forbidden. SUPER_ADMIN only.', status: 403);
    }
    throw ApiException('Failed to deactivate admin (${res.statusCode}).',
        status: res.statusCode);
  }
  // Add to AdminManagementService
Future<void> activate({
  required String token,
  required int id,
}) async {
  final res = await _client.put(
    _u('/api/admin/super/admins/$id'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (res.statusCode == 200 || res.statusCode == 204) return;

  if (res.statusCode == 401) {
    throw ApiException('Unauthorized. Please login again.', status: 401);
  }
  if (res.statusCode == 403) {
    throw ApiException('Forbidden. SUPER_ADMIN only.', status: 403);
  }
  throw ApiException('Failed to activate admin (${res.statusCode}).',
      status: res.statusCode);
}

}
