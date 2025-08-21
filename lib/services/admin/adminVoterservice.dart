import 'dart:convert';
import 'package:evote/models/voter.dart';
import 'package:http/http.dart' as http;





class VoterService {
  final http.Client _client;
  final String baseUrl;
  VoterService({http.Client? client, required this.baseUrl })
      : _client = client ?? http.Client();

  Future<List<VoterDto>> list({required String token}) async {
    final uri = Uri.parse('$baseUrl/api/admin/voters');
    final res = await _client.get(uri, headers: {'Authorization': 'Bearer $token'});

    if (res.statusCode == 200) {
      final arr = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
      return arr.map(VoterDto.fromJson).toList();
    }
    if (res.statusCode == 401) {
      throw ApiException('Unauthorized. Please login again.', status: 401);
    }
    if (res.statusCode == 403) {
      throw ApiException('Forbidden. Not enough privileges.', status: 403);
    }
    throw ApiException('Server error (${res.statusCode}).', status: res.statusCode);
  }

  // Backend returns a User entity; we just ensure 200/201 and refresh the list in UI.
  Future<void> create({
    required String token,
    required String nic,
    required String fullName,
    required int divisionId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/admin/voters');
    final res = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nic': nic,
        'fullName': fullName,
        'divisionId': divisionId,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) return;

    if (res.statusCode == 401) {
      throw ApiException('Unauthorized. Please login again.', status: 401);
    }
    if (res.statusCode == 403) {
      throw ApiException('Only SUPER_ADMIN can add voters.', status: 403);
    }
    throw ApiException('Failed to create voter (${res.statusCode}).',
        status: res.statusCode);
  }
}
