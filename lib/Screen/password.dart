import 'package:evote/Screen/login.dart';
import 'package:evote/widget/background.dart';
import 'package:evote/widget/button.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class Password extends StatefulWidget {
  const Password({super.key});

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordCController = TextEditingController();
 bool _isRegistered = false;

  void _handleRegistration() {
    setState(() {
      _isRegistered = true;
    });
   Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
        );
      }
    });
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
                    // Note: You need to add lottie dependency to pubspec.yaml
                    // and import 'package:lottie/lottie.dart';
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
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height:100),
                CustomTextFormField(
                  controller: _passwordController,
                  hintText: "Enter Password",
                  labelText: "Password",
                ),
                const SizedBox(height: 25),
                CustomTextFormField(
                  controller: _passwordCController,
                  hintText: "Confirm Password",
                  labelText: "Confirm Password",
                  
                ),
                const SizedBox(height: 40),
                GestureDetector(
                      onTap: _handleRegistration,
                      child: Button(text: "submit".tr),
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