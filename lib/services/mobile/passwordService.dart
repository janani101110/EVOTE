import 'dart:convert';
import 'package:http/http.dart' as http;

class PasswordService {
  final String baseUrl;

  PasswordService({required this.baseUrl});

  Future<Map<String, dynamic>> setPassword(String nic, String password) async {
    if (password.isEmpty) {
      throw Exception("Password cannot be empty");
    }

    final url = Uri.parse('$baseUrl/api/voting/set-password');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nic": nic, "password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

}