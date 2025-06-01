import 'package:evote/Screen/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class Biometric extends StatefulWidget {
  const Biometric({super.key});

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
      bool authenticated = await auth.stopAuthentication();
      await auth.authenticate(
        localizedReason: 'must MFA',
        options: AuthenticationOptions(
          stickyAuth: false,
          biometricOnly: true,
        ),
      );
      if (authenticated) {
        Navigator.push(context,
            MaterialPageRoute( builder: (context) => Dashboard()));
      }
      print("Authenticated: $authenticated");
    } on PlatformException catch (e) {
      print(e);
    }
  }

  
}