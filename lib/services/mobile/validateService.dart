import 'dart:convert';

import 'package:http/http.dart' as http;

class Validateservice {
  final String baseUrl;

  Validateservice({required this.baseUrl});

  Future<Map<String, dynamic>> validateNIC(String nic) async {
    if (nic.isEmpty) {
      throw Exception("NIC cannot be empty");
    }
    final url = Uri.parse('$baseUrl/api/voting/validate-nic');
    final response = await http.post(
      url,
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({"nic":nic}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}