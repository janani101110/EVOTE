import 'package:evote/models/division.dart';
import 'package:evote/models/voter.dart';
import 'package:evote/services/admin/adminDivisionservice.dart';
import 'package:evote/services/admin/adminVoterservice.dart';
import 'package:evote/services/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Adminvoters extends StatefulWidget {
  const Adminvoters({super.key});

  @override
  State<Adminvoters> createState() => _AdminvotersState();
}

class _AdminvotersState extends State<Adminvoters> {
  final _voterService = VoterService(baseUrl: baseUrl);
  final _divisionService = DivisionService(baseUrl: baseUrl);

  final TextEditingController _searchController = TextEditingController();

  String? _token;
  String? _role;

  List<VoterDto> _all = [];
  List<VoterDto> _filtered = [];
  bool _loading = true;
  String? _error;

  bool get _isSuperAdmin => _role == 'SUPER_ADMIN';

  @override
  void initState() {
    super.initState();
    _init();
    _searchController.addListener(_applyFilter);
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('admin_jwt');
    _role = prefs.getString('admin_role');

    if (_token == null || _token!.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Not authenticated. Please login.';
      });
      return;
    }
    await _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _voterService.list(token: _token!);
      setState(() {
        _all = list;
        _filtered = List.from(_all);
      });
      _applyFilter();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = _all
          .where((v) => v.nic.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddDialog() {
    if (!_isSuperAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only SUPER_ADMIN can add voters.')),
      );
      return;
    }

    String nic = '';
    String fullName = '';
    int? selectedDivisionId;
    List<DivisionDto> divisions = [];
    bool loadingDivs = true;
    String? loadErr;
    bool submitting = false;

    showDialog(
      context: context,
      barrierDismissible: !submitting,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) {
          // load divisions once
          if (loadingDivs && loadErr == null) {
            _divisionService.list(token: _token!).then((list) {
              if (!ctx.mounted) return;
              setLocal(() {
                divisions = list;
                loadingDivs = false;
              });
            }).catchError((e) {
              if (!ctx.mounted) return;
              setLocal(() {
                loadErr = e.toString();
                loadingDivs = false;
              });
            });
          }

          return AlertDialog(
            title: const Text('Add Voter'),
            content: loadingDivs
                ? const SizedBox(
                    height: 80, child: Center(child: CircularProgressIndicator()))
                : loadErr != null
                    ? SizedBox(
                        width: 320,
                        child: Text(loadErr!, style: const TextStyle(color: Colors.red)),
                      )
                    : SizedBox(
                        width: 360,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              decoration: const InputDecoration(hintText: 'NIC'),
                              onChanged: (v) => nic = v.trim(),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              decoration:
                                  const InputDecoration(hintText: 'Full name'),
                              onChanged: (v) => fullName = v.trim(),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              value: selectedDivisionId,
                              items: divisions
                                  .map((d) => DropdownMenuItem<int>(
                                        value: d.id,
                                        child: Text('${d.code} — ${d.name}'),
                                      ))
                                  .toList(),
                              onChanged: (v) => selectedDivisionId = v,
                              decoration: const InputDecoration(
                                hintText: 'Select division',
                              ),
                            ),
                          ],
                        ),
                      ),
            actions: [
              TextButton(
                onPressed: submitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: submitting || loadingDivs || loadErr != null
                    ? null
                    : () async {
                        if (nic.isEmpty || fullName.isEmpty || selectedDivisionId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill all fields.')),
                          );
                          return;
                        }
                        setLocal(() => submitting = true);
                        try {
                          await _voterService.create(
                            token: _token!,
                            nic: nic,
                            fullName: fullName,
                            divisionId: selectedDivisionId!,
                          );
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Voter added')),
                            );
                            _fetch();
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        } finally {
                          setLocal(() => submitting = false);
                        }
                      },
                child: submitting
                    ? const SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator())
                    : const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                height: 80,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Voters',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _openAddDialog,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:
                              _isSuperAdmin ? Colors.purple[900] : Colors.purple[100],
                        ),
                        child: Row(
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

              // Search
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by NIC...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // List
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: _filtered.isEmpty
                      ? const Center(child: Text('No voters found.'))
                      : Column(
                          children: [
                            // header row
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Expanded(flex: 2, child: Text('NIC', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Expanded(flex: 2, child: Text('Division', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Expanded(flex: 2, child: Text('Has Voted', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filtered.length,
                              itemBuilder: (context, i) {
                                final v = _filtered[i];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 8),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade200,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(flex: 2, child: Text(v.fullName)),
                                      Expanded(flex: 2, child: Text(v.nic)),
                                      Expanded(flex: 2, child: Text(v.divisionCode)),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          v.hasVoted == null
                                              ? '-' // backend doesn't supply this in VoterResponse
                                              : (v.hasVoted! ? 'Yes' : 'No'),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
