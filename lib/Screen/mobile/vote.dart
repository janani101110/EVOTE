import 'dart:convert';

import 'package:evote/Screen/mobile/candidatelist.dart';
import 'package:evote/Screen/mobile/dashboard.dart';
import 'package:evote/widget/background.dart';
import 'package:evote/widget/button.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Vote extends StatefulWidget {
  final int userId;
  final String userDivision; // ✅ Add this
  final List<Map<String, String>> candidate;

  const Vote({
    super.key,
    required this.candidate,
    required this.userId,
    required this.userDivision, // ✅ Add this
  });

  @override
  State<Vote> createState() => _VoteState();
}

class _VoteState extends State<Vote> with TickerProviderStateMixin {
  bool showAnimation = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _onSubmitPressed() async {
    if (widget.candidate.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print("🔐 Token: $token");

    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login again.")));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.144:8080/api/voting/vote'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "candidateIds":
              widget.candidate.map((c) => int.parse(c["id"]!)).toList(),
          "userId": widget.userId,
          "userDivision": widget.userDivision,
        }),
      );

      print("📡 Status Code: ${response.statusCode}");
      print("📦 Response Body: '${response.body}'");

      if (response.statusCode == 200 ||
          response.statusCode == 400 ||
          response.statusCode == 403) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);

          if (data['success']) {
            setState(() => showAnimation = true);
            _controller.repeat(reverse: true);

            await Future.delayed(const Duration(seconds: 4));

            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => Dashboard(
                        userId: widget.userId,
                        userDivision: widget.userDivision,
                        hasVoted: true,
                      ),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'] ?? 'Failed to vote')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server returned empty response.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('HTTP Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exception: $e')));
    }
  }

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
          if (showAnimation)
            _buildAnimationScreen()
          else
            _buildVoteConfirmation(),
        ],
      ),
    );
  }

  Widget _buildAnimationScreen() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'vote3'.tr,
              style: const TextStyle(
                color: Color.fromRGBO(111, 44, 145, 1),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 75),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: Image.asset('assets/finger.png', width: 200, height: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteConfirmation() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Center(
            child: Text(
              'confirm'.tr,
              style: const TextStyle(
                color: Color.fromRGBO(111, 44, 145, 1),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 85),
          Column(
            children:
                widget.candidate.map((candidate) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: InkWell(
                      child: Container(
                        padding: const EdgeInsets.all(25.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.account_circle,
                              size: 50,
                              color: Color.fromRGBO(111, 44, 145, 1),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  candidate['name']!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  candidate['party']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 40),
          Button(
            text: 'submit'.tr,
            onPressed: _onSubmitPressed,
            isCancel: false, // Not a cancel button
          ),

          const SizedBox(height: 60),

          Button(
            text: 'cancel'.tr,
            onPressed: () {
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
            },
            isCancel:
                true, // This is a cancel button, will use the cancel style
          ),
        ],
      ),
    );
  }
}
