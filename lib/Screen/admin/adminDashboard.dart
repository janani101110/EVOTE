import 'dart:async';

import 'package:evote/widget/piechart.dart';
import 'package:flutter/material.dart';

class Admindashboard extends StatefulWidget {
  const Admindashboard({super.key});

  @override
  State<Admindashboard> createState() => _AdmindashboardState();
}

class _AdmindashboardState extends State<Admindashboard> {
  final List<Map<String, dynamic>> partyData = [
    {'name': 'Unity Party', 'logo': '55', 'votes': 1200},
    {'name': 'Progress Alliance', 'logo': '55', 'votes': 950},
    {'name': 'Future Front', 'logo': '55', 'votes': 850},
  ];

  String currentPhase = 'Voting';
  late Duration timeLeft;
  late Timer _timer;

  final DateTime phaseEndTime = DateTime(2025, 6, 30, 17, 0, 0); // Example

  @override
  void initState() {
    super.initState();
    timeLeft = phaseEndTime.difference(DateTime.now());
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final difference = phaseEndTime.difference(now);
      if (difference.isNegative) {
        _timer.cancel();
        setState(() {
          currentPhase = 'Counting';
          timeLeft = Duration.zero;
        });
      } else {
        setState(() {
          timeLeft = difference;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SingleChildScrollView(
        
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Election status box
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 20.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Current Election Status',
                    style: TextStyle(
                      color: Colors.black26,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 50),
                  const Text(
                    'Election Name',
                    style: TextStyle(
                      color: Color.fromARGB(255, 115, 115, 116),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 50),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: const Color.fromARGB(255, 173, 255, 176),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        color: Color.fromARGB(194, 2, 124, 8),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(), // Pushes the image to the end
                  SizedBox(
                    height: double.infinity, // Fits full container height
                    child: Image.asset(
                      'assets/bannerimg.png',
                      fit: BoxFit.fitHeight, // Ensures it respects height
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),

            // Pie chart and leaderboard side-by-side
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pie Chart Card
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(253, 249, 249, 250),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: const Color(0xFF7E57C2)),
                    boxShadow: [
                      BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text(
                        'Voter Turnout',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 26, 1, 123),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        height: 350,
                        width: 350,
                        child: Piechart(totalVoters: 1000, votesCast: 750),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 50),

                // Leaderboard card
                Container(
                  width: 350,
                  height: 425,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(253, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10.0),
                  
                  border: Border.all(color: const Color(0xFF7E57C2)),
                    boxShadow: [
                      BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Leader Board',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 26, 1, 123),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.separated(
                          itemCount: partyData.length,
                          separatorBuilder:
                              (context, index) =>
                                  const Divider(color: Color.fromARGB(255, 134, 130, 130)),
                          itemBuilder: (context, index) {
                            final party = partyData[index];
                            return Row(
                              children: [
                                const Icon(Icons.flag, color: Color.fromARGB(255, 26, 1, 123)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    party['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 134, 130, 130),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${party['votes']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 134, 130, 130),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 50),

                //timeline
                Container(
                  width: 350,
                  height: 425,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(251, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: const Color(0xFF7E57C2)),
                    boxShadow: [
                      BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Election Timeline',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 26, 1, 123),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 60),
                      Text(
                        'Current Phase: $currentPhase',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 134, 130, 130),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Icon(Icons.timer, size: 60, color: Color.fromARGB(255, 26, 1, 123)),
                      const SizedBox(height: 16),
                      Text(
                        _formatDuration(timeLeft),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 134, 130, 130),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Time remaining',
                        style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 134, 130, 130)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
