// import 'dart:convert';
import 'package:evote/Screen/mobile/candidatelist.dart';
import 'package:evote/Screen/mobile/language.dart';
import 'package:evote/services/mobile/loginService.dart';
import 'package:evote/services/services.dart';
import 'package:evote/widget/background.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dashboard extends StatefulWidget {
  final int userId;
  final String userDivision;
  final bool hasVoted;

  const Dashboard({
    required this.userId,
    required this.userDivision,
    required this.hasVoted,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String? userDivision;
  bool hasVoted = false; // Initialize with default value

  @override
  void initState() {
    super.initState();
    _initAnimation();

    // ✅ Assign passed values to local state
    userDivision = widget.userDivision;
    hasVoted = widget.hasVoted;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  void _initAnimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

void _logout() async {
  final authService = LoginService(baseUrl: baseUrl);

  try {
    final result = await authService.logout();

    if (mounted) {
      // Check if result contains success key and it's true
      final bool success = result['success'] == true;

      if(success){
         Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Language()),
        (route) => false,
      );
      }
     
    }
  } catch (e) {
    if (mounted) {
      // Still navigate to login screen on error
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Language()),
        (route) => false,
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(),
      body: Stack(
        children: [
          Background(),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/fp.jpeg',
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.5,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.5,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 300),
                _buildContainer('election'.tr),
                const SizedBox(height: 30),
                widget.hasVoted
                    ? _buildThankYouButton()
                    : _buildDivision(widget.userDivision),

                const SizedBox(height: 50),
                hasVoted ? _buildlogout() : _buildVoteButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainer(String text) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 80),
      padding: const EdgeInsets.all(16),
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
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDivision(String text) {
    return _buildContainer(text);
  }

  Widget _buildlogout() {
    return ElevatedButton(
      onPressed: _logout,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Center(
        child: Text(
          'tnk'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVoteButton() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: ElevatedButton(
        onPressed: () {
          // Navigate to candidate selection or other voting screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => Candidatelist(
                    userId: widget.userId,
                    userDivision: widget.userDivision,
                  ),
            ),
          );
          print('Vote button pressed for user: ');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Center(
          child: Text(
            'vote1'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThankYouButton() {
    return _buildContainer('vote2'.tr);
  }
}
