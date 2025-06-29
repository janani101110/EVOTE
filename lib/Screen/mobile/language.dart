import 'package:evote/Screen/mobile/validLogin.dart';
import 'package:evote/widget/background.dart';
import 'package:evote/widget/navbar.dart';
import 'package:evote/widget/button.dart'; // Import your Button widget
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Language extends StatefulWidget {
  const Language({super.key});

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Navbar(),
      body: Stack(
        children: [
          const Background(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and text section
              Align(
                alignment: const Alignment(0.2, -0.3),
                child: SizedBox(
                  height: 150,
                  width: 150,
                  child: Stack(
                    children: [
                      Container(
                        height: 150,
                        width: 100,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/logo.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const Align(
                        alignment: Alignment(-1.6, 1.2),
                        child: Text(
                          'මැතිවරණ කොමිෂන් සභාව',
                          style: TextStyle(fontSize: 9, color: Colors.black),
                        ),
                      ),
                      const Align(
                        alignment: Alignment(-1.1, 1.4),
                        child: Text(
                          'தேர்தல் ஆணைக்குழு',
                          style: TextStyle(color: Colors.black, fontSize: 9),
                        ),
                      ),
                      const Align(
                        alignment: Alignment(-0.8, 1.6),
                        child: Text(
                          'Election Commission',
                          style: TextStyle(color: Colors.black, fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 100),
              
              // Language selection buttons - Centered
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Sinhala Button
                  Align(
                    alignment: Alignment.center,
                    child: Button(
                      text: 'Sinhala',
                      onPressed: () {
                        var locale = const Locale('si', 'LK');
                        Get.updateLocale(locale);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Validlogin()),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Tamil Button
                  Align(
                    alignment: Alignment.center,
                    child: Button(
                      text: 'Tamil',
                      onPressed: () {
                        var locale = const Locale('ta', 'LK');
                        Get.updateLocale(locale);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Validlogin()),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // English Button
                  Align(
                    alignment: Alignment.center,
                    child: Button(
                      text: 'English',
                      onPressed: () {
                        var locale = const Locale('en', 'US');
                        Get.updateLocale(locale);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Validlogin()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}