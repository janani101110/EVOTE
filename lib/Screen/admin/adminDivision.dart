import 'package:evote/models/division.dart';
import 'package:evote/services/admin/adminDivisionservice.dart';
import 'package:evote/services/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDivision extends StatefulWidget {
  const AdminDivision({super.key});

  @override
  State<AdminDivision> createState() => _AdminDivisionState();
}

class _AdminDivisionState extends State<AdminDivision> {
  final _service = DivisionService(baseUrl: baseUrl);

  List<DivisionDto> _divisions = [];
  bool _isLoadingList = true;
  bool _isSubmitting = false;
  String? _error;

  String? _token;
  String? _role;

  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _code = '';

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
    await _fetchDivisions();
  }

  Future<void> _fetchDivisions() async {
    setState(() {
      _isLoadingList = true;
      _error = null;
    });
    try {
      final list = await _service.list(token: _token!);
      setState(() => _divisions = list);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoadingList = false);
    }
  }

  void _showAddDialog() {
    if (!_isSuperAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only SUPER_ADMIN can add divisions.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: const Text('Add Division'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Division name'),
                  onSaved: (v) => _name = v?.trim() ?? '',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter division name' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Division code'),
                  onSaved: (v) => _code = v?.trim() ?? '',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter division code' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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
                          code: _code,
                        );
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Division added')),
                          );
                          _fetchDivisions();
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
                      width: 18, height: 18, child: CircularProgressIndicator())
                  : const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _divisions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: RefreshIndicator(
        onRefresh: _fetchDivisions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      'Divisions',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Total: $total',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 115, 115, 116),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: _showAddDialog,
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

              const SizedBox(height: 25),

              
              if (_isLoadingList)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                )
              else if (_divisions.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('No divisions found.'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _divisions.length,
                  itemBuilder: (context, index) {
                    final d = _divisions[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.apartment),
                        title: Text(d.name),
                        subtitle: Text(d.code),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
