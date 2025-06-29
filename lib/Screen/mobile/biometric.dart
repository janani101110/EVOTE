

import 'package:evote/Screen/mobile/dashboard.dart';
import 'package:evote/widget/background.dart';
import 'package:evote/widget/button.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class Biometric extends StatefulWidget {
  final int userId;
  final String userDivision;
  final bool hasVoted;

  const Biometric({
    super.key,
    required this.userId,
    required this.userDivision,
    required this.hasVoted,
  });

  @override
  State<Biometric> createState() => _BiometricState();
}

class _BiometricState extends State<Biometric> {
  late final LocalAuthentication auth;
  bool _supportState = false; 

  @override
  void initState() {
    super.initState();
    auth = LocalAuthentication();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() {
            _supportState = isSupported;
          }),
          
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(),
      body: Stack(
        children: [
          Background(),
Center(
  child: Column(
    mainAxisSize: MainAxisSize.max,
    children: [
      const SizedBox(height: 245),

      _supportState
          ? const Text('This is supported',style: TextStyle(color: Colors.purple,fontSize: 20,fontWeight: FontWeight.bold),)
          : const Text('not supported'),
      const SizedBox(height: 20),
      const Icon(
        Icons.fingerprint,
        size: 100,
        color: Colors.purpleAccent,
      ),
      const SizedBox(height: 80),
      Button(
        onPressed: _authenticate,
        text: 'Click to authenticate',
      ),
    ],
  ),
),
        ],
      ),
    );
  }

  Future<void> _authenticate() async {
  try {
    await auth.stopAuthentication();

    final bool authenticated = await auth.authenticate(
      localizedReason: 'Please authenticate to proceed',
      options: const AuthenticationOptions(
        biometricOnly: false, // ✅ Allow fallback to PIN/Pattern/Passcode
        useErrorDialogs: true,
        stickyAuth: true,
      ),
    );

    if (authenticated && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute( 
          builder: (context) => Dashboard(
            userId: widget.userId,
            userDivision: widget.userDivision,
            hasVoted: widget.hasVoted,
          ),
        ),
      );
    }
  } on PlatformException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Authentication error: ${e.message}")),
    );
  }
}


  
}