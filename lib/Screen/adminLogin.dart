import 'dart:async';
import 'package:evote/Screen/admin/adminMain.dart';
import 'package:evote/Screen/desktop/desktop_candidate.dart';
import 'package:evote/services/admin/adminloginservice.dart';
import 'package:evote/services/services.dart';
import 'package:evote/widget/background.dart';
import 'package:evote/widget/button.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Adminlogin extends StatefulWidget {
  const Adminlogin({super.key});

  @override
  State<Adminlogin> createState() => _AdminloginState();
}

class _AdminloginState extends State<Adminlogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _auth = AdminAuthService(baseUrl: baseUrl);

  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

Future<void> _doLogin() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);
  try {
    final result = await _auth.login(_emailCtrl.text.trim(), _pwdCtrl.text);

    // Persist token & auth info for later requests
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_jwt', result.token);
    await prefs.setString('admin_role', result.role);
    await prefs.setInt('admin_id', result.adminId);
    if (result.divisionId != null) {
      await prefs.setInt('division_id', result.divisionId!);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login successful')),
    );

    // Navigate based on role
    Widget nextScreen;
    if (result.role == 'SUPER_ADMIN') {
      nextScreen = const Adminmain();
    } else {
      nextScreen = const DesktopCandidate(); // Make sure to import DesktopCandidate
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  } on AuthException catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message)),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Something went wrong. Please try again.')),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  String? _emailValidator(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Email is required';
    if (!value.contains('@')) return 'Enter a valid email';
    return null;
    // For stronger validation you can use a proper regex.
  }

  String? _passwordValidator(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return 'Password is required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Navbar(),
      body: Stack(
        children: [
          Positioned.fill(child: const Background()),
          Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 150,
                        width: 100,
                        child: Image.asset('assets/logo.png'),
                      ),
                      const SizedBox(height: 8),
                      const Column(
                        children: [
                          Text('මැතිවරණ කොමිෂන් සභාව',
                              style: TextStyle(fontSize: 12, color: Colors.black)),
                          Text('தேர்தல் ஆணைக்குழு',
                              style: TextStyle(fontSize: 12, color: Colors.black)),
                          Text('Election Commission',
                              style: TextStyle(fontSize: 12, color: Colors.black)),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Admin Login',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(111, 44, 145, 1),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _emailCtrl,
                          obscureText: false,
                          keyboardType: TextInputType.emailAddress,
                          validator: _emailValidator,
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _pwdCtrl,
                          obscureText: true,
                          validator: _passwordValidator,
                          decoration: const InputDecoration(
                            hintText: 'Password',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Submit
                      Center(
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : Button(
                                text: 'Enter',
                                onPressed: _doLogin,
                                // onPressed:() {
                                //   Navigator.push(context, MaterialPageRoute(builder: (context)=> Adminmain()));
                                // },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
