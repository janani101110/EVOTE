import 'package:evote/models/candidate.dart';
import 'package:evote/services/admin/adminCandidateservice.dart';
import 'package:evote/services/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Admincandidate extends StatefulWidget {
  const Admincandidate({super.key});

  @override
  State<Admincandidate> createState() => _AdmincandidateState();
}

class _AdmincandidateState extends State<Admincandidate> {
  final _service = CandidateService(baseUrl: baseUrl);

  List<CandidateDto> _candidates = [];
  bool _isLoadingList = true;
  bool _isSubmitting = false;
  String? _error;
  String? _token;
  String? _role;

  // Form state
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _party = '';
  String _candidateCode = '';

  bool get _isSuperAdmin => _role == 'SUPER_ADMIN';

  @override
  void initState() {
    super.initState();
    _loadAuthAndFetch();
  }

  Future<void> _loadAuthAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('admin_jwt');
    final role = prefs.getString('admin_role');

    setState(() {
      _token = token;
      _role = role;
    });

    if (token == null || token.isEmpty) {
      setState(() {
        _isLoadingList = false;
        _error = 'Not authenticated. Please login.';
      });
      return;
    }
    await _fetchCandidates();
  }

  Future<void> _fetchCandidates() async {
    setState(() {
      _isLoadingList = true;
      _error = null;
    });
    try {
      final list = await _service.list(token: _token!);
      setState(() {
        _candidates = list;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoadingList = false);
    }
  }

  void _showAddCandidateForm() {
    if (!_isSuperAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only SUPER_ADMIN can add candidates.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: const Text("Add Candidate"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Name"),
                    onSaved: (val) => _name = val?.trim() ?? '',
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? "Enter name" : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Party"),
                    onSaved: (val) => _party = val?.trim() ?? '',
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? "Enter party" : null,
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: "Candidate Code"),
                    onSaved: (val) => _candidateCode = val?.trim() ?? '',
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? "Enter Candidate Code"
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      _formKey.currentState!.save();

                      setLocalState(() => _isSubmitting = true);
                      try {
                        await _service.create(
                          token: _token!,
                          name: _name,
                          party: _party,
                          candidateCode: _candidateCode,
                        );
                        if (mounted) {
                          Navigator.pop(context); // close dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Candidate added')),
                          );
                          _fetchCandidates(); // refresh list
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      } finally {
                        setLocalState(() => _isSubmitting = false);
                      }
                    },
              child: _isSubmitting
                  ? const SizedBox(
                      height: 18, width: 18, child: CircularProgressIndicator())
                  : const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _candidates.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: RefreshIndicator(
        onRefresh: _fetchCandidates,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Candidate List',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black26,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 25),
                    Text(
                      'Total Number of candidates: $total',
                      style: const TextStyle(
                          color: Color.fromARGB(255, 115, 115, 116),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _showAddCandidateForm,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _isSuperAdmin
                              ? Colors.purple[900]
                              : Colors.purple[100],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Add',
                              style: TextStyle(
                                color:
                                    _isSuperAdmin ? Colors.white : Colors.black45,
                              ),
                            ),
                            Icon(Icons.add,
                                color:
                                    _isSuperAdmin ? Colors.white : Colors.black45),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Body content
              if (_isLoadingList)
                const Center(child: Padding(
                  padding: EdgeInsets.only(top: 40.0),
                  child: CircularProgressIndicator(),
                ))
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (_candidates.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 24.0),
                  child: Text('No candidates found.'),
                )
              else
                ..._candidates.map(
                  (c) => Card(
                    child: ListTile(
                      title: Text(c.name),
                      subtitle: Text('Party: ${c.party}'),
                      trailing: Text(c.candidateCode),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
