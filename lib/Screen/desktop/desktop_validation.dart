import 'package:evote/Screen/desktop/desktop_candidate.dart';
import 'package:evote/services/mobile/validateService.dart';
import 'package:evote/services/services.dart';
import 'package:evote/widget/background.dart';
import 'package:evote/widget/button.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';

class DesktopValidation extends StatefulWidget {
  const DesktopValidation({super.key});

  @override
  State<DesktopValidation> createState() => _DesktopValidationState();
}

class _DesktopValidationState extends State<DesktopValidation> {
  final TextEditingController nicController = TextEditingController();
  // ignore: unused_field
  bool _isRegistered = false;
  
  Future<void> _validate() async {
  final nic = nicController.text.trim().toUpperCase();

  final oldNic = RegExp(r'^\d{9}[VX]$');
  final newNic = RegExp(r'^\d{12}$');

  if (!(oldNic.hasMatch(nic) || newNic.hasMatch(nic))) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('NIC format is wrong')),
    );
    return;
  }

  try {
    final validateService = Validateservice(baseUrl: baseUrl);
    final result = await validateService.validateNIC(nic);

    final success = result['success'] == true;
    final Map<String, dynamic>? data =
        (result['data'] is Map) ? Map<String, dynamic>.from(result['data']) : null;

    if (success && data != null) {
      
      int? id;
      final rawId = data['id'];
      if (rawId is int) {
        id = rawId;
      }

      final hasVoted = data['hasVoted'] == true;

      if (id == null) {
        setState(() => _isRegistered = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid response: voter ID missing')),
        );
        return;
      }

      setState(() => _isRegistered = true);
      if (!mounted) return;

      if (!hasVoted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DesktopCandidate(id: id!)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Already voted')),
        );
      }
    } else {
      setState(() => _isRegistered = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']?.toString() ?? 'NIC not registered')),
      );
    }
  } catch (e) {
    setState(() => _isRegistered = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(),
      body: Stack(
        children: [
          const Background(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(111, 44, 145, 1),
                      Color.fromRGBO(199, 1, 127, 1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 130),
                    const Text(
                      'Presidential Election 2024',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 400),
                    SizedBox(
                      width: 200,
                      height: 150,
                      child: Image.asset(
                        'assets/bannerimg.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              Text("Enter your NIC"),
              SizedBox(
                width: 400,
              child: 
              TextFormField(
              
                controller: nicController,
                decoration: const InputDecoration(
                  
                  border: OutlineInputBorder(),
                  labelText: 'NIC',
                  hintText: 'Enter your NIC',
                ),
              ),),
              SizedBox(height: 50,),
              Button(text: "Enter",
              onPressed: _validate,),
            ],
          ),
        ],
      ),
    );
  }
}
