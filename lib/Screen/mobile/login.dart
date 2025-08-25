import 'package:evote/Screen/mobile/biometric.dart';
import 'package:evote/services/mobile/loginService.dart';
import 'package:evote/services/services.dart';
import 'package:evote/widget/background.dart';
import 'package:evote/widget/button.dart';
import 'package:evote/widget/customTextFormField.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isRegistered = false;


//login function
  void _handleLogin() async {
  final nic = _nicController.text.trim().toUpperCase();
  final password = _passwordController.text.trim();

  if(nic.isEmpty||password.isEmpty){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('NIC and Password cannot be empty')));
    return;
  }
  final oldNic = RegExp(r'^\d{9}[VX]$') ;
  final newNic = RegExp(r'^\d{12}$');

if (!(oldNic.hasMatch(nic) || newNic.hasMatch(nic))) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('NIC format is wrong')),
    );
    return;
  }

  try {
    final loginService = LoginService(baseUrl: baseUrl);
    final result = await loginService.login(nic, password); //importing the service

    if (result['success'] == true) { //mapping the response
      final user = result['user'];
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
            builder: (context) => Biometric( //passing the needed attributes
              userId: userId,
              userDivision: divisionName,
              hasVoted: hasVoted,
            ),
          ),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 100),
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
                      suffixIcon: true,
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: _handleLogin,
                      child: Button(text: "log".tr),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
