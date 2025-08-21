import 'package:evote/models/admin.dart';
import 'package:evote/models/division.dart';
import 'package:evote/services/admin/adminManageservice.dart';
import 'package:evote/services/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:evote/services/admin/adminDivisionservice.dart'; // your divisions service

class AdminAdmins extends StatefulWidget {
  const AdminAdmins({super.key});

  @override
  State<AdminAdmins> createState() => _AdminAdminsState();
}

class _AdminAdminsState extends State<AdminAdmins> {
  final _svc = AdminManagementService(baseUrl: baseUrl);
  final _divSvc = DivisionService(baseUrl: baseUrl);

  String? _token;
  String? _role;
  bool get _isSuperAdmin => _role == 'SUPER_ADMIN';

  List<AdminUserDto> _admins = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final p = await SharedPreferences.getInstance();
    _token = p.getString('admin_jwt');
    _role = p.getString('admin_role');

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
      final list = await _svc.list(token: _token!);
      setState(() => _admins = list);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openAddDialog() {
    if (!_isSuperAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only SUPER_ADMIN can create admins.')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    String fullName = '';
    String email = '';
    String password = '';
    String role = 'DIVISIONAL_ADMIN'; // default
    int? divisionId;

    bool loadingDivs = true;
    String? divError;
    bool submitting = false;

    List<DivisionDto> divisions = [];

    showDialog(
      context: context,
      barrierDismissible: !submitting,
      builder:
          (_) => StatefulBuilder(
            builder: (ctx, setLocal) {
              if (loadingDivs && divError == null) {
                _divSvc
                    .list(token: _token!)
                    .then((list) {
                      if (!ctx.mounted) return;
                      setLocal(() {
                        divisions = list;
                        loadingDivs = false;
                      });
                    })
                    .catchError((e) {
                      if (!ctx.mounted) return;
                      setLocal(() {
                        divError = e.toString();
                        loadingDivs = false;
                      });
                    });
              }

              return AlertDialog(
                title: const Text('Create Admin'),
                content: SizedBox(
                  width: 420,
                  child:
                      loadingDivs
                          ? const SizedBox(
                            height: 80,
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : divError != null
                          ? Text(
                            divError!,
                            style: const TextStyle(color: Colors.red),
                          )
                          : Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Full name',
                                  ),
                                  onSaved: (v) => fullName = v?.trim() ?? '',
                                  validator:
                                      (v) =>
                                          (v == null || v.trim().isEmpty)
                                              ? 'Enter name'
                                              : null,
                                ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  onSaved: (v) => email = v?.trim() ?? '',
                                  validator: (v) {
                                    final t = v?.trim() ?? '';
                                    if (t.isEmpty) return 'Enter email';
                                    if (!t.contains('@'))
                                      return 'Enter a valid email';
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                  ),
                                  obscureText: true,
                                  onSaved: (v) => password = v ?? '',
                                  validator:
                                      (v) =>
                                          (v == null || v.isEmpty)
                                              ? 'Enter password'
                                              : null,
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: role,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'DIVISIONAL_ADMIN',
                                      child: Text('DIVISIONAL_ADMIN'),
                                    ),
                                  ],
                                  onChanged: (v) => role = v!,
                                  decoration: const InputDecoration(
                                    labelText: 'Role',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<int>(
                                  value: divisionId,
                                  isExpanded: true,
                                  items: [
                                    const DropdownMenuItem<int>(
                                      value: null,
                                      child: Text('— No division —'),
                                    ),
                                    ...divisions.map(
                                      (d) => DropdownMenuItem<int>(
                                        value: d.id,
                                        child: Text('${d.code} — ${d.name}'),
                                      ),
                                    ),
                                  ],
                                  onChanged: (v) => divisionId = v,
                                  decoration: const InputDecoration(
                                    labelText: 'Division (optional)',
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
                actions: [
                  TextButton(
                    onPressed: submitting ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed:
                        submitting || loadingDivs || divError != null
                            ? null
                            : () async {
                              if (!formKey.currentState!.validate()) return;
                              formKey.currentState!.save();

                              setLocal(() => submitting = true);
                              try {
                                await _svc.create(
                                  token: _token!,
                                  fullName: fullName,
                                  email: email,
                                  password: password,
                                  role: role,
                                  divisionId: divisionId,
                                );
                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Admin created'),
                                    ),
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
                    child:
                        submitting
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(),
                            )
                            : const Text('Create'),
                  ),
                ],
              );
            },
          ),
    );
  }

  Future<void> _confirmDeactivate(AdminUserDto a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Deactivate admin?'),
            content: Text('Are you sure you want to deactivate ${a.fullName}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Deactivate'),
              ),
            ],
          ),
    );
    if (ok != true) return;

    try {
      await _svc.deactivate(token: _token!, id: a.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${a.fullName} deactivated')));
      _fetch();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _confirmActivate(AdminUserDto a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Activate admin?'),
            content: Text('Are you sure you want to activate ${a.fullName}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Activate'),
              ),
            ],
          ),
    );
    if (ok != true) return;

    try {
      await _svc.activate(token: _token!, id: a.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${a.fullName} activated')));
      _fetch();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    const Text(
                      'Admins',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (_isSuperAdmin)
                      GestureDetector(
                        onTap: _openAddDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.purple[900],
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Add',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.add, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!_loading && _error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              if (!_loading && _error == null && !_isSuperAdmin)
                const Text('Forbidden. SUPER_ADMIN only.'),
              if (!_loading &&
                  _error == null &&
                  _isSuperAdmin &&
                  _admins.isEmpty)
                const Text('No admins found.'),
              if (!_loading &&
                  _error == null &&
                  _isSuperAdmin &&
                  _admins.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _admins.length,
                  itemBuilder: (context, i) {
                    final a = _admins[i];
                    return Card(
                      child: ListTile(
                        title: Text('${a.fullName}  •  ${a.role}'),
                        subtitle: Text(
                          a.email +
                              (a.divisionId == null
                                  ? ''
                                  : '  •  Division ID: ${a.divisionId}'),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    a.active
                                        ? Colors.green[100]
                                        : Colors.red[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(a.active ? 'Active' : 'Inactive'),
                            ),
                            const SizedBox(width: 12),
                            if (a.active)
                              IconButton(
                                tooltip: 'Deactivate',
                                icon: const Icon(Icons.person_off),
                                onPressed: () => _confirmDeactivate(a),
                              )
                            else
                              IconButton(
                                tooltip: 'Activate',
                                icon: const Icon(Icons.person_add_alt_1),
                                onPressed: () => _confirmActivate(a),
                              ),
                          ],
                        ),
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
