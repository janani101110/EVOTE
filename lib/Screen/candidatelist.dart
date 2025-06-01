import 'package:evote/Screen/vote.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Candidatelist extends StatefulWidget {
  const Candidatelist({super.key});

  @override
  State<Candidatelist> createState() => _CandidatelistState();
}

class _CandidatelistState extends State<Candidatelist> {
  final List<Map<String, String>> candidates = [
    {'name': 'Janantha Jayakantha', 'party': 'National Rabbit Congrass'},
    {'name': 'Chandrakumara', 'party': 'United Brilliant Party'},
    {'name': 'Anuhas Kapila', 'party': 'National SecondOver Party'},
    {'name': 'Cocomelon', 'party': 'Sri Lanka Coconut Party'},
    {'name': 'Candidate 5', 'party': 'Party E'},
    {'name': 'Candidate 6', 'party': 'Party F'},
  ];

  List<Map<String, String>> selectedCandidates = [];

  void _toggleSelection(Map<String, String> candidate) {
    setState(() {
      if (selectedCandidates.contains(candidate)) {
        selectedCandidates.remove(candidate);
      } else {
        if (selectedCandidates.length < 3) {
          selectedCandidates.add(candidate);
        } else {
          // Show a message when more than 3 are selected
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You can select only 3 candidates'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _confirmVote() {
    if (selectedCandidates.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Vote(candidate: selectedCandidates,
            
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Center(
              child: Text(
                'candi1'.tr,
                style: TextStyle(
                  color: Color.fromRGBO(111, 44, 145, 1),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'election'.tr,
              style: TextStyle(
                color: Color.fromRGBO(111, 44, 145, 1),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: List.generate(candidates.length, (index) {
                    final candidate = candidates[index];
                    final isSelected = selectedCandidates.contains(candidate);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: InkWell(
                        onTap: () => _toggleSelection(candidate),
                        child: Container(
                          padding: const EdgeInsets.all(25.0),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green[100] : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromRGBO(111, 44, 145, 1)
                                    .withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Display the dynamic number based on `isSelected` state
                              Text(
                                isSelected
                                    ? (selectedCandidates.indexOf(candidate) + 1)
                                        .toString()
                                    : '', // Display rank based on selection order
                                style: TextStyle(
                                  fontSize: 30,
                                  color: isSelected ? Colors.green : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10), // Adjust space between number and icon

                              // Icon to represent the selection state
                              Icon(
                                isSelected ? Icons.numbers_rounded : Icons.circle_outlined,
                                size: 30,
                                color: isSelected ? Colors.green : Colors.grey,
                              ),
                              const SizedBox(width: 20), // Space between icon and candidate name

                              // Column displaying candidate's name and party
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    candidate['name']!,
                                    style: TextStyle(
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
                  }),
                ),
              ),
            ),

            // Confirm Button
            ElevatedButton(
              onPressed: selectedCandidates.isNotEmpty ? _confirmVote : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedCandidates.isNotEmpty
                    ? Color.fromRGBO(111, 44, 145, 1)
                    : Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Text(
                'Confirm Vote',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}