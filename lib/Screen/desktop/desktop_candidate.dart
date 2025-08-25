import 'package:evote/Screen/desktop/desktop_vote.dart';
import 'package:evote/models/candidate.dart';
import 'package:evote/services/admin/adminCandidateservice.dart';
import 'package:evote/services/services.dart';
import 'package:evote/widget/background.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DesktopCandidate extends StatefulWidget {
  final int id;
  const DesktopCandidate({super.key, required this.id});

  @override
  State<DesktopCandidate> createState() => _DesktopCandidateState();
}

class _DesktopCandidateState extends State<DesktopCandidate> {
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

  Future<void> _confirmVote() async {
    if (selectedCandidates.isNotEmpty) {
      // Attach rank (1-based) according to the selection order
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
              (context) => DesktopVote(candidates: withRank, id: widget.id),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCandidates();
  }

  Future<void> fetchCandidates() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('admin_jwt'); // <- use getter

      if (token == null || token.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No auth token found. Please login again."),
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      final candidateService = CandidateService(baseUrl: baseUrl);
      final List<CandidateDto> list = await candidateService.list(token: token);

      if (!mounted) return;
      setState(() {
        candidates =
            list
                .map<Map<String, String>>(
                  (c) => {
                    'id': c.id.toString(),
                    'name': c.name,
                    'party': c.party,
                  },
                )
                .toList();
        isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(),
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
                      child: Image.asset(
                        'assets/bannerimg.png',
                        fit: BoxFit.fill,
                      ),
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
              isLoading
                  ? SizedBox(
                    // height: constraints.maxHeight * 0.6,
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : Expanded(
                    child: ListView.builder(
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
                              ), // Reduced padding
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
                                      (selectedCandidates.indexOf(candidate) +
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
                                        isSelected ? Colors.green : Colors.grey,
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
                  ),

              ElevatedButton(
                onPressed: selectedCandidates.isNotEmpty ? _confirmVote : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedCandidates.isNotEmpty
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
        ],
      ),
    );
  }
}
