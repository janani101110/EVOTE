
import 'package:evote/Screen/mobile/candidatelist.dart';
import 'package:evote/Screen/mobile/dashboard.dart';
import 'package:evote/services/services.dart';
import 'package:evote/services/mobile/voteService.dart';
import 'package:evote/widget/background.dart';
import 'package:evote/widget/button.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart'; 
import 'package:get/get.dart';

class Vote extends StatefulWidget {
  final int userId;
  final String userDivision; 
  final List<Map<String, String>> candidate;

  const Vote({
    super.key,
    required this.candidate,
    required this.userId,
    required this.userDivision,
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


//voting function
void _onSubmitPressed() async {
  if (widget.candidate.isEmpty) return;

  try {
    final voteService = VoteService(baseUrl: baseUrl);
    final token = await voteService.getAuthToken();//importing service to loa token

    if (token == null) {
      showSnackBar("Please login again.");
      return;
    }

    final sortedByRank = List<Map<String, String>>.from(widget.candidate) //sorting by rank
      ..sort((a, b) => (int.tryParse(a['rank'] ?? '999') ?? 999)
          .compareTo(int.tryParse(b['rank'] ?? '999') ?? 999));

    final candidateIds = sortedByRank.map((c) => int.parse(c["id"]!)).toList();

    final result = await voteService.submitVote( //importing the service
      candidateIds: candidateIds,
      userId: widget.userId,
      userDivision: widget.userDivision,
      token: token,
    );

    if (result['success'] == true) {
      setState(() => showAnimation = true);
      _controller.repeat(reverse: true);

      await Future.delayed(const Duration(seconds: 4));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Dashboard(
              userId: widget.userId,
              userDivision: widget.userDivision,
              hasVoted: true, // passing the hasvoted true
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
            isCancel: false, 
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
                true, 
          ),
        ],
      ),
    );
  }
}
