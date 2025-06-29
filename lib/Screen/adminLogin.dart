import 'package:evote/Screen/admin/adminMain.dart';
import 'package:evote/widget/background.dart';
import 'package:evote/widget/button.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';

class Adminlogin extends StatefulWidget {
  const Adminlogin({super.key});

  @override
  State<Adminlogin> createState() => _AdminloginState();
}

class _AdminloginState extends State<Adminlogin> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: const Navbar(),
      body: Stack(
        children: [
          const Background(),
          Column( 
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              SizedBox(
                height: 150,
                width: 100,
                child: Image.asset('assets/logo.png', fit: BoxFit.cover),
              ),

              const SizedBox(height: 10),

              // Election Commission Texts
              Column(
                children: const [
                  Text(
                    'මැතිවරණ කොමිෂන් සභාව',
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  Text(
                    'தேர்தல் ஆணைக்குழு',
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  Text(
                    'Election Commission',
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Admin Login Title
              const Text(
                'Admin Login',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(111, 44, 145, 1),
                ),
              ),

              const SizedBox(height: 20),

              // Password Input Field with Shorter Width
              SizedBox(
                width: 300, // Shorter width
                child: TextFormField(
                  obscureText: true, // Hide password
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Submit Button
              Center(
                child: Button(text: 'Enter',
                onPressed: (){
                    Navigator.push(context, 
                    MaterialPageRoute(
                      builder: (context)=> Adminmain()
                      )
                    );
                },)
              ),
            ],
          ),
       ] ),
      );
  
  }
}
