import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginService{
  final String baseUrl;

  LoginService({required this.baseUrl});

  Future<Map<String, dynamic>> login(String nic, String password) async{
    if(nic.isEmpty || password.isEmpty) {
      throw Exception("NIC and Password cannot be empty");
    }
    final url = Uri.parse('$baseUrl/api/voting/login');
    final response = await http.post(
      url,
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({"nic":nic,"password":password}),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if(json['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', json['data']['token']);

          return {
            'success': true,
            'user': json['data']['user'],
          };
        } else {
          throw Exception(json['message'] ?? "login failed");
        }
      }else {
      throw Exception("Login failed. Please check your NIC and password.");

      }
  }
  // In LoginService class
Future<Map<String, dynamic>> logout() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.post(
      Uri.parse('$baseUrl/api/voting/logout'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    // Always clear local storage regardless of server response
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_division');
    await prefs.remove('has_voted');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? true,
        'message': data['message'] ?? 'Logged out successfully'
      };
    } else {
      return {
        'success': false,
        'message': 'Logout failed: ${response.statusCode}'
      };
    }
  } catch (e) {
    // Still clear local storage even if there's an error
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    
    return {
      'success': false,
      'message': 'Logout error: ${e.toString()}'
    };
  }
}
}