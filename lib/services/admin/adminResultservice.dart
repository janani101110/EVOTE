// lib/services/results_service.dart
import 'dart:convert';
import 'package:evote/models/results.dart';
import 'package:http/http.dart' as http;





class ResultsService {
  final http.Client _client;
  final String baseUrl;
  ResultsService({http.Client? client, required this.baseUrl})
      : _client = client ?? http.Client();
       

  Uri _u(String p) => Uri.parse('$baseUrl$p');

  Future<ElectionResult> electionResults({required String token}) async {
    final res = await _client.get(
      _u('/api/admin/results/election'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Optional: quick sanity check to help debugging
    print('RESULTS BODY: ${res.statusCode} -> ${res.body}');

    if (res.statusCode == 200) {
      final body = res.body.trim();
      if (body.isEmpty) {
        // no payload -> return empty result safely
        return ElectionResult.fromAny({});
      }
      final decoded = jsonDecode(body);
      return ElectionResult.fromAny(decoded);
    }
    if (res.statusCode == 401) {
      throw ApiException('Unauthorized. Please login again.', status: 401);
    }
    if (res.statusCode == 403) {
      throw ApiException('Forbidden. SUPER_ADMIN only.', status: 403);
    }
    throw ApiException('Server error (${res.statusCode}).', status: res.statusCode);
  }
}