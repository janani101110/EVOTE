// lib/services/division_service.dart
import 'dart:convert';
import 'package:evote/models/division.dart';
import 'package:http/http.dart' as http;




class DivisionService {
  final http.Client _client;
  final String baseUrl;

  DivisionService({http.Client? client, required this.baseUrl })
      : _client = client ?? http.Client();

  Future<List<DivisionDto>> list({required String token}) async {
    final uri = Uri.parse('$baseUrl/api/admin/divisions');
    final res = await _client.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final list = (jsonDecode(res.body) as List)
          .cast<Map<String, dynamic>>()
          .map(DivisionDto.fromJson)
          .toList();
      return list;
    }

    if (res.statusCode == 401) {
      throw ApiException('Unauthorized. Please login again.', status: 401);
    }
    if (res.statusCode == 403) {
      throw ApiException('Forbidden. Not enough privileges.', status: 403);
    }
    throw ApiException('Server error (${res.statusCode}).', status: res.statusCode);
  }

  Future<DivisionDto> create({
    required String token,
    required String name,
    required String code,
  }) async {
    final uri = Uri.parse('$baseUrl/api/admin/divisions');
    final res = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name, 'code': code}),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return DivisionDto.fromJson(json);
    }

    if (res.statusCode == 401) {
      throw ApiException('Unauthorized. Please login again.', status: 401);
    }
    if (res.statusCode == 403) {
      throw ApiException('Only SUPER_ADMIN can add divisions.', status: 403);
    }
    throw ApiException('Failed to create division (${res.statusCode}).',
        status: res.statusCode);
  }
}
