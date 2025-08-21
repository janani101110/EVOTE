import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VoteService {
  final String baseUrl;

  VoteService({required this.baseUrl});

  Future<Map<String, dynamic>> submitVote({
    required List<int> candidateIds,
    required int userId,
    required String userDivision,
    required String token,
  }) async {
    if (token.isEmpty) {
      throw Exception("Token cannot be empty");
    }

    if (candidateIds.isEmpty) {
      throw Exception("No candidates selected");
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/voting/vote'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "candidateIds": candidateIds,
        "userId": userId,
        "userDivision": userDivision,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 400 || response.statusCode == 403) {
      if (response.body.isEmpty) {
        throw Exception("Server returned empty response");
      }
      return jsonDecode(response.body);
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}