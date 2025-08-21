// lib/services/candidate_service.dart
import 'dart:convert';
import 'package:evote/models/candidate.dart';
import 'package:http/http.dart' as http;






class CandidateService {
  final http.Client _client;
  final String baseUrl;
  CandidateService({http.Client? client, required this.baseUrl })
      : _client = client ?? http.Client();

  Future<List<CandidateDto>> list({required String token}) async {
    final uri = Uri.parse('$baseUrl/api/admin/candidates');
    final res = await _client.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final list = (jsonDecode(res.body) as List)
          .cast<Map<String, dynamic>>()
          .map(CandidateDto.fromJson)
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

  Future<CandidateDto> create({
    required String token,
    required String name,
    required String party,
    required String candidateCode,
  }) async {
    final uri = Uri.parse('$baseUrl/api/admin/candidates');
    final res = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'party': party,
        'candidateCode': candidateCode,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      // Controller returns the created Candidate entity.
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return CandidateDto.fromJson(json);
    }

    if (res.statusCode == 401) {
      throw ApiException('Unauthorized. Please login again.', status: 401);
    }
    if (res.statusCode == 403) {
      throw ApiException('Only SUPER_ADMIN can add candidates.', status: 403);
    }
    throw ApiException('Failed to create candidate (${res.statusCode}).',
        status: res.statusCode);
  }
}
