import 'package:evote/Screen/mobile/login.dart';
import 'package:evote/Screen/mobile/validationForm.dart';
import 'package:evote/widget/background.dart';
import 'package:evote/widget/button.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class Validlogin extends StatefulWidget {
  const Validlogin({super.key});

  @override
  State<Validlogin> createState() => _ValidloginState();
}

class _ValidloginState extends State<Validlogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: Navbar(),
      body: Stack(
        children: [
          Background(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                    ]
                  )
               )
              ),
              const SizedBox(height: 25,),
              Button(text: "reg".tr, //language translation
              onPressed: () => Navigator.push(context, 
              MaterialPageRoute(builder: (context)=>const Validationform())
              ),
              ),
              const SizedBox(height: 10,),
              Button(text: 'log'.tr,
              onPressed: () => Navigator.push(context, 
              MaterialPageRoute(builder: (context)=>const Login())
              ),
              ),
            ],
          )
        ],
      ),
    );
  }
}