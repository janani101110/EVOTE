import 'package:evote/Screen/desktop/desktop_vote.dart';
import 'package:evote/widget/background.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';

class DesktopCandidate extends StatefulWidget {
  const DesktopCandidate({super.key});

  @override
  State<DesktopCandidate> createState() => _DesktopCandidateState();
}

class _DesktopCandidateState extends State<DesktopCandidate> {
 final List<Map<String, String>> candidates = [
    {'name': 'Janantha Jayakantha', 'party': 'National Rabbit Congrass'},
    {'name': 'Chandrakumara', 'party': 'United Brilliant Party'},
    {'name': 'Anuhas Kapila', 'party': 'National SecondOver Party'},
    {'name': 'Cocomelon', 'party': 'Sri Lanka Coconut Party'},
    {'name': 'Candidate 5', 'party': 'Party E'},
    {'name': 'Candidate 6', 'party': 'Party F'},
  ];

  List<Map<String, String>> selectedCandidates = [];

  void _castVote(Map<String, String> candidate) {
    setState(() {
      if (selectedCandidates.contains(candidate)) {
        selectedCandidates.remove(candidate);
      } else {
        if (selectedCandidates.length < 3) {
          selectedCandidates.add(candidate);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You can select up to 3 candidates'),
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
          builder: (context) => DesktopVote(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  Navbar(),
      body: Stack(
        children: [
          const Background(),
           Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 150,
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
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 130),
                  const Text(
                    'Presidential Election 2024',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 400),
                  SizedBox(
                    width: 200,
                    height: 150,
                    child: Image.asset('assets/bannerimg.png', fit: BoxFit.fill),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Center(
              child: Text(
                'Select Your Candidate For Presidential Election 2024',
                style: TextStyle(
                  color: Color.fromRGBO(111, 44, 145, 1),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
                        onTap: () => _castVote(candidate),
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
                              Text(
                                isSelected
                                    ? (selectedCandidates.indexOf(candidate) + 1)
                                        .toString()
                                    : '',
                                style: TextStyle(
                                  fontSize: 30,
                                  color: isSelected ? Colors.green : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                size: 30,
                                color: isSelected ? Colors.green : Colors.grey,
                              ),
                              const SizedBox(width: 200),
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
     ] ),
    );
  }
}
