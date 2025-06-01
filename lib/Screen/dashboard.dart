// import 'dart:convert';
import 'package:evote/Screen/candidatelist.dart';
import 'package:evote/widget/background.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dashboard extends StatefulWidget {
  // final int userId;
  // final String? nic; // Optional NIC (needed only at login)
  // final bool? hasVoted;
 
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String? userDivision;
  bool hasVoted = false; // Initialize with default value

  @override
  void initState() {
    super.initState();
    _initAnimation();
    // Initialize hasVoted - you can set this based on your logic
    // hasVoted = widget.hasVoted ?? false; // Uncomment when you have the parameter
    
    // _fetchUserDivision();
    // Ensure UI rebuilds properly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  void _initAnimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  // Future<void> _fetchUserDivision() async {
  //   final url = Uri.parse('http://10.0.2.2:8080/api/division?nic=${widget.nic}');
  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       setState(() {
  //         userDivision = data['division'] ?? "Division not found";
  //       });
  //     } else {
  //       setState(() => userDivision = "User not found");
  //     }
  //   } catch (error) {
  //     setState(() => userDivision = "Unknown");
  //   }
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                hasVoted
                    ? _buildThankYouButton()
                    : _buildDivision(userDivision ?? "Loading..."),
                const SizedBox(height: 50),
                hasVoted ? Container() : _buildVoteButton(),
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
          colors: [Color.fromRGBO(111, 44, 145, 1), Color.fromRGBO(199, 1, 127, 1)],
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

  Widget _buildVoteButton() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: ElevatedButton(
        onPressed: () {
          // Navigate to candidate selection or other voting screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Candidatelist()),
          );
          print('Vote button pressed for user: ');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Center(
          child: Text(
            'vote1'.tr,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildThankYouButton() {
    return _buildContainer('vote2'.tr);
  }
}