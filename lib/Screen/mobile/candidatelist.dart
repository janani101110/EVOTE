import 'package:evote/Screen/mobile/vote.dart';
import 'package:evote/services/mobile/candidateService.dart';
import 'package:evote/services/services.dart';
import 'package:evote/widget/button.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Candidatelist extends StatefulWidget {
  final int userId;
  final String userDivision;
  const Candidatelist({
    super.key,
    required this.userId,
    required this.userDivision,
  });

  @override
  State<Candidatelist> createState() => _CandidatelistState();
}

class _CandidatelistState extends State<Candidatelist> {
  List<Map<String, String>> candidates = [];
  bool isLoading = true;
  List<Map<String, String>> selectedCandidates = [];


// limiting to select only 3 candidates
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
      // Attach rank according to the selection order (manapa)
      final withRank =
          selectedCandidates.asMap().entries.map((entry) {
            final c = Map<String, String>.from(entry.value);
            c['rank'] = (entry.key + 1).toString(); 
            return c;
          }).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => Vote(
                candidate: withRank,
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


//fetching the candidates
  void fetchCandidates() async {
    try {
     
      final candidateService = CandidateService(baseUrl: baseUrl);

      
      final token = await candidateService.getAuthToken(); //importing service to laod token

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No auth token found. Please login again.")),
          );
        }
        return;
      }

      
      final result = await candidateService.fetchCandidates(token);// Use the service method to fetch candidates

      if (result['success'] == true) {
        final List<dynamic> candidateData = result['data'];

        setState(() {
          candidates = //candidate deails
              candidateData.map<Map<String, String>>((c) {
                return {
                  'id': c['id'].toString(), 
                  'name': c['candidateName'] ?? '',
                  'party': c['partyName'] ?? '',
                };
              }).toList();
          isLoading = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? "Failed to fetch candidates"),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(16.0), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                  
                    Column(
                      children: [
                        Text(
                          'candi1'.tr,
                          style: TextStyle(
                            color: Color.fromRGBO(111, 44, 145, 1),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'election'.tr,
                          style: TextStyle(
                            color: Color.fromRGBO(111, 44, 145, 1),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Candidates List
                    isLoading
                        ? SizedBox(
                          height: constraints.maxHeight * 0.6,
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: candidates.length,
                          itemBuilder: (context, index) {
                            final candidate = candidates[index];
                            final isSelected = selectedCandidates.contains(
                              candidate,
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: InkWell(
                                onTap: () => _toggleSelection(candidate),
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    16.0,
                                  ), 
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? Colors.green[100]
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromRGBO(
                                          111,
                                          44,
                                          145,
                                          1,
                                        ).withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      if (isSelected)
                                        Text(
                                          (selectedCandidates.indexOf(
                                                    candidate,
                                                  ) +
                                                  1)
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      SizedBox(width: isSelected ? 10 : 0),
                                      Icon(
                                        isSelected
                                            ? Icons.numbers_rounded
                                            : Icons.circle_outlined,
                                        size: 24,
                                        color:
                                            isSelected
                                                ? Colors.green
                                                : Colors.grey,
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              candidate['name']!,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              candidate['party']!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                    
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Button(
                        text: 'Confirm Vote',
                        onPressed: _confirmVote,
                        isCancel: selectedCandidates.isNotEmpty,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
