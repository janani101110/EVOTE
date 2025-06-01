import 'package:evote/Screen/language.dart';
import 'package:evote/localString.dart';
import 'package:evote/widget/background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: Localstrings(),
      locale: Locale('en','US'),
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      
        
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  

  @override
  void initState() {
    super.initState();
    // Wait for 3 seconds and navigate to Login
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Language()),
      );
    });
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Stack(
        children: [
          Background(),
        ],
      ),
    );
  }
}