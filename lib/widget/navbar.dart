import 'package:flutter/material.dart';

class Navbar extends StatefulWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(0, 249, 248, 248),
      elevation: 0,
      
      automaticallyImplyLeading: false, // Removes default back button
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            // Left: Logo
            Container(
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                'assets/logo.png', // Replace with your logo path
                height: 45,
                width: 45,
                fit: BoxFit.contain,
              ),
            ),
            
            const SizedBox(width: 16), // Space between logo and text
            
            // Center: Three language texts
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'මැතිවරණ කොමිෂන් සභාව',
                    style: TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'தேர்தல் ஆணைக்குழு',
                    style: TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Election Commission',
                    style: TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                ],
              ),
            ),
            
            // Right: Space for additional items (logout button, etc.)
            // You can add more widgets here if needed
          ],
        ),
      ),
    );
  }
}