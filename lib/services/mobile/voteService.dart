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
  Future<Map<String, dynamic>> submitpollingVote({
  required List<int> candidateIds,
  required int userId,
  required String token,
}) async {
  if (token.isEmpty) {
    throw Exception("Token cannot be empty");
  }

  if (candidateIds.isEmpty) {
    throw Exception("No candidates selected");
  }

  final response = await http.post(
    Uri.parse('$baseUrl/api/admin/super/admins/vote/by-admin'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      "candidateIds": candidateIds,
      "userId": userId,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 400 || response.statusCode == 403) {
    if (response.body.isEmpty) {
      throw Exception("Server returned empty response");
    }
    
    // Ensure we always return a Map<String, dynamic>
    final decodedResponse = jsonDecode(response.body);
    
    if (decodedResponse is Map<String, dynamic>) {
      return decodedResponse;
    } else if (decodedResponse is bool) {
      // Convert bool response to Map
      return {'success': decodedResponse};
    } else {
      // Handle other unexpected types
      return {'success': false, 'message': 'Unexpected response format'};
    }
  } else {
    throw Exception('Server error: ${response.statusCode}');
  }
}
}