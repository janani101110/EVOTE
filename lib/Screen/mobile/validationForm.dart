
import 'package:evote/Screen/mobile/password.dart';
import 'package:evote/services/services.dart';
import 'package:evote/services/mobile/validateService.dart';
import 'package:evote/widget/background.dart';
import 'package:evote/widget/button.dart';
import 'package:evote/widget/customTextFormField.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class Validationform extends StatefulWidget {
  const Validationform({super.key});

  @override
  State<Validationform> createState() => _ValidationformState();
}

class _ValidationformState extends State<Validationform> {
  final TextEditingController _nicController = TextEditingController(); //controllers for input fields
  final TextEditingController _nameController = TextEditingController();
  bool _isRegistered = false;


// validation function
 Future<void> _handleRegistration() async {
  final nic = _nicController.text.trim().toUpperCase();
  final name = _nameController.text.trim();

  if (nic.isEmpty ||name.isEmpty ){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('NIC and Name should not be empty')));
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
    final validateService = Validateservice(baseUrl: baseUrl); 
    final result = await validateService.validateNIC(nic);// importing the service

    setState(() {
      _isRegistered = result['success'] == true;
    });

    if (result['success'] == true) {
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Password(nic: nic)),
        );
      }
    }
  } catch (e) {
    setState(() {
      _isRegistered = false;
    });
    
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
    _nameController.dispose();
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
                      'assets/Done.json', 
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
                      "reg".tr,
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
                      controller: _nameController,
                      hintText: "Enter Full Name",
                      labelText: "Full Name",
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: _handleRegistration,
                      child: Button(text: "reg".tr),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
