
import 'package:evote/Screen/mobile/login.dart';
import 'package:evote/services/mobile/passwordService.dart';
import 'package:evote/services/services.dart';
import 'package:evote/widget/background.dart';
import 'package:evote/widget/button.dart';
import 'package:evote/widget/customTextFormField.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class Password extends StatefulWidget {
  final String nic;

  const Password({super.key, required this.nic});

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordCController = TextEditingController();
  bool _isRegistered = false;

  void _handlePassword() async {
  final password = _passwordController.text.trim();
  final confirmPassword = _passwordCController.text.trim();

  
  if (password.isEmpty || confirmPassword.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password fields cannot be empty")),
    );
    return;
  }

  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Passwords do not match")),
    );
    return;
  }

  try {
    final passwordService = PasswordService(baseUrl: baseUrl);
    final result = await passwordService.setPassword(widget.nic, password);

    if (result['success'] == true) {
      setState(() {
        _isRegistered = true;
      });

      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${result['message']}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordCController.dispose();
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
                      "password".tr,
                      style: const TextStyle(
                        color: Colors.purple,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 100),
                    CustomTextFormField(
                      controller: _passwordController,
                      hintText: "Enter Password",
                      labelText: "Password",
                      suffixIcon: true,
                    ),
                    const SizedBox(height: 25),
                    CustomTextFormField(
                      controller: _passwordCController,
                      hintText: "Confirm Password",
                      labelText: "Confirm Password",
                      suffixIcon: true,
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: _handlePassword,
                      child: Button(text: "submit".tr),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
