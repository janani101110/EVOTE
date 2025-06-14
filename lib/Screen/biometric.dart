

import 'package:evote/Screen/dashboard.dart';
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (_supportState)
            const Text('This is supported')
          else
            const Text('not supported'),
          const Divider(height: 100),
          
          ElevatedButton(
            onPressed: _authenticate,
            child: Text('Click to authenticate'),
          )
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