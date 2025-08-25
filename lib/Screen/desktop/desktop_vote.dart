import 'package:evote/Screen/desktop/desktop_candidate.dart';
import 'package:evote/Screen/desktop/desktop_validation.dart';
import 'package:evote/services/services.dart';
import 'package:evote/widget/background.dart';
import 'package:evote/widget/button.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/mobile/voteService.dart';

class DesktopVote extends StatefulWidget {
  final List<Map<String, String>> candidates;
  final int id;
  

  const DesktopVote({super.key,
    required this.candidates,
    required this.id,
   
  });

  @override
  State<DesktopVote> createState() => _DesktopVoteState();
}

class _DesktopVoteState extends State<DesktopVote> with TickerProviderStateMixin {
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
  if (widget.candidates.isEmpty) return;

  try {
    final voteService = VoteService(baseUrl: baseUrl);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('admin_jwt');

    if (token == null) {
      showSnackBar("Please login again.");
      return;
    }

    final sortedByRank = List<Map<String, String>>.from(widget.candidates)
      ..sort((a, b) => (int.tryParse(a['rank'] ?? '999') ?? 999)
          .compareTo(int.tryParse(b['rank'] ?? '999') ?? 999));

    final candidateIds = sortedByRank.map((c) => int.parse(c["id"]!)).toList();

    final result = await voteService.submitpollingVote(
      candidateIds: candidateIds,
      userId: widget.id,
      token: token
     
      
    );
print(result);
    if (result['success'] == true) {
      setState(() => showAnimation = true);
      _controller.repeat(reverse: true);

      await Future.delayed(const Duration(seconds: 4));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DesktopValidation(
              
            ),
          ),
        );
      }
    } else {
      showSnackBar(result['message'] ?? 'Failed to vote');
    }
  } catch (e) {
    showSnackBar(e.toString());
  }
}

void showSnackBar(String message) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
      appBar: const Navbar(),
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
                widget.candidates.map((candidate) {
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
            isCancel: false, 
          ),

          const SizedBox(height: 40),

          Button(
            text: 'cancel'.tr,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => DesktopCandidate(
                            id: widget.id,
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