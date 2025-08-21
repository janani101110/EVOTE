import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CandidateService {
  final String baseUrl;

  CandidateService({required this.baseUrl});

  Future<Map<String, dynamic>> fetchCandidates(String token) async {
    if (token.isEmpty) {
      throw Exception("Token cannot be empty");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/voting/candidates'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      throw Exception("Access denied. Please login again.");
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  // You can add more candidate-related methods here
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}