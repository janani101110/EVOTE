import 'dart:convert';

import 'package:evote/Screen/mobile/vote.dart';
import 'package:evote/widget/button.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Candidatelist extends StatefulWidget {
  final int userId;
  final String userDivision;
  const Candidatelist({super.key,required this.userId,required this.userDivision});

  @override
  State<Candidatelist> createState() => _CandidatelistState();
}

class _CandidatelistState extends State<Candidatelist> {
  List<Map<String, String>> candidates = [];
bool isLoading = true;
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
    builder: (context) => Vote(
      candidate: selectedCandidates, // 👈 already has id, name, and party
      userId: widget.userId,
      userDivision: widget.userDivision,
    ),
  ),
);
    }
  }
  @override
void initState() {
  super.initState();
  fetchCandidates();
}

void fetchCandidates() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null) {
    SnackBar(content: Text("No auth token found. Please login again."));
    return;
  }

  final response = await http.get(
    Uri.parse('http://192.168.1.144:8080/api/voting/candidates'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token", // 🔐 Include the token
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      final List<dynamic> candidateData = data['data'];

      setState(() {
  candidates = candidateData.map<Map<String, String>>((c) {
  return {
    'id': c['id'].toString(), // ✅ Add this line
    'name': c['candidateName'] ?? '',
    'party': c['partyName'] ?? '',
  };
}).toList();

  isLoading = false;
});
    } else {
      SnackBar(content: Text(data['message']));
    }
  } else if (response.statusCode == 403) {
    SnackBar(content: Text("Access denied. Please login again."));
  } else {
    SnackBar(content: Text("Server error: ${response.statusCode}"));
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
  child: isLoading
      ? const Center(child: CircularProgressIndicator())
      : SingleChildScrollView(
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
            Button(
  text: 'Confirm Vote',
  onPressed: selectedCandidates.isNotEmpty ? _confirmVote : null, // Disable button if candidates are empty
  isCancel: selectedCandidates.isNotEmpty, // Pass isEnabled based on selectedCandidates
)

          ],
        ),
      ),
    );
  }
}