import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool? isCancel;

  const Button({
    super.key,
    required this.text,
    this.onPressed,
    this.isCancel =false
  });

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 50,
        width: 200,
        

        decoration: widget.isCancel == true
            ? BoxDecoration(
              border: Border.all(
                color: Colors.purple,
              ),
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                
              )
            : BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(111, 44, 145, 1),
                    Color.fromRGBO(199, 1, 127, 1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          ),
          child: Text(
            widget.text,
            style: widget.isCancel==false
            ?const TextStyle(color: Colors.white)
            :const TextStyle(color: Colors.purple)
            
          ),
        ),
      ),
    );
  }
}