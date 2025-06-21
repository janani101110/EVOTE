import 'package:evote/Screen/biometric.dart';
import 'package:evote/widget/background.dart';
import 'package:evote/widget/button.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
 import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
 bool _isRegistered = false;

 



void _handleLogin() async {
  final nic = _nicController.text.trim();
  final password = _passwordController.text.trim();

  if (nic.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("NIC and Password cannot be empty")),
    );
    return;
  }

  final url = Uri.parse('http://192.168.1.144:8080/api/voting/login');
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"nic": nic, "password": password}),
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);

    if (json['success'] == true) {
      final token = json['data']['token'];
      final user = json['data']['user'];

      // ✅ Save token for use in future authenticated requests
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      final userId = user['id'];
      final division = user['division'] ?? {};
final divisionName = division['divisionName'] ?? 'Unknown';
final hasVoted = user['hasVoted'] ?? false;



      setState(() {
        _isRegistered = true;
      });

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => Biometric(
      userId: userId,
      userDivision: divisionName,
      hasVoted: hasVoted,
    ),
  ),
);

      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${json['message']}")),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Server error: ${response.statusCode}')),
    );
  }
}



  @override
  void dispose() {
    _nicController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(),
      body: Stack(
        children: [
          Background(),
          _isRegistered 
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    const SizedBox(height: 20),
                    
                    Lottie.asset(
                      'assets/Done.json', // Path to your JSON file
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              )
            : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 60),
                Text(
                  "log".tr,
                  style: const TextStyle(
                    color: Colors.purple,
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height:100),
                CustomTextFormField(
                  controller: _nicController,
                  hintText: "Enter NIC",
                  labelText: "NIC",
                ),
                const SizedBox(height: 25),
                CustomTextFormField(
                  controller: _passwordController,
                  hintText: "Enter Password",
                  labelText: "Password",
                  
                ),
                const SizedBox(height: 40),
                GestureDetector(
                      onTap: _handleLogin,
                      child: Button(text: "log".tr),
                    )
              ],
            ),
          )
        ],
      ),
    );
  }

}
class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
      